import XCTest
@testable import Orb

final class ItemPinControllerTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var repository: ItemRepository!
    private var controller: ItemPinController!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-pin-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = ItemRepository(manager: manager)
        controller = ItemPinController(repository: repository)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testTogglePinUpdatesItem() throws {
        let saved = try repository.create(Item(type: .text, title: "Pin me"))
        XCTAssertFalse(saved.isPinned)
        let pinned = try controller.togglePin(item: saved)
        XCTAssertTrue(pinned.isPinned)
    }

    func testPinnedItemsSortHigher() throws {
        let a = Item(type: .text, title: "A", isPinned: false, sortOrder: 0)
        let b = Item(type: .text, title: "B", isPinned: true, sortOrder: 1)
        let sorted = controller.sortPinnedFirst([a, b])
        XCTAssertEqual(sorted.first?.title, "B")
    }
}
