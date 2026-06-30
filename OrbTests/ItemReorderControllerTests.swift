import XCTest
@testable import Orb

final class ItemReorderControllerTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var repository: ItemRepository!
    private var controller: ItemReorderController!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-reorder-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = ItemRepository(manager: manager)
        controller = ItemReorderController(repository: repository)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testReorderUpdatesSortMetadata() throws {
        let first = try repository.create(Item(type: .text, title: "First", sortOrder: 0))
        let second = try repository.create(Item(type: .text, title: "Second", sortOrder: 1))
        try controller.reorder(itemIDs: [second.id, first.id])
        let items = try repository.listRecent()
        let firstOrder = items.first { $0.id == first.id }?.sortOrder
        let secondOrder = items.first { $0.id == second.id }?.sortOrder
        XCTAssertEqual(secondOrder, 0)
        XCTAssertEqual(firstOrder, 1)
    }
}
