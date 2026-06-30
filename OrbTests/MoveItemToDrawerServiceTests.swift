import XCTest
@testable import Orb

final class MoveItemToDrawerServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var service: MoveItemToDrawerService!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-move-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        service = MoveItemToDrawerService(items: ItemRepository(manager: manager))
    }

    override func tearDownWithError() throws { manager.close() }

    func testMoveUpdatesDrawerId() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Work"))
        let item = try items.create(Item(type: .text, title: "Task"))
        try service.move(itemID: item.id, toDrawer: drawer.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, drawer.id)
    }

    func testMoveToNilGoesToInbox() throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Inbox"))
        try service.move(itemID: item.id, toDrawer: nil)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, DefaultDataSeeder.inboxDrawerID)
    }
}
