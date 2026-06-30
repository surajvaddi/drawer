import XCTest
@testable import Orb

final class DrawerRowDropHandlerTests: XCTestCase {
    private var manager: DatabaseManager!
    private var handler: DrawerRowDropHandler!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-row-drop-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        handler = DrawerRowDropHandler(moveService: MoveItemToDrawerService(items: ItemRepository(manager: manager)))
    }

    override func tearDownWithError() throws { manager.close() }

    func testDropOnDrawerRowMovesItem() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Target"))
        let item = try items.create(Item(type: .text, title: "Move"))
        try handler.drop(itemID: item.id, onDrawer: drawer.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, drawer.id)
    }
}
