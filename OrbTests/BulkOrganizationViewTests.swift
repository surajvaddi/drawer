import XCTest
@testable import Orb

final class BulkOrganizationViewTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testBulkMoveInLibrary() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let target = try drawers.create(Drawer(name: "Target", sortOrder: 99))
        let item = try items.create(Item(type: .text, title: "MoveMe", contentText: "x"))
        let mover = MoveItemToDrawerService(items: items)
        try mover.move(itemID: item.id, toDrawer: target.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, target.id)
    }
}
