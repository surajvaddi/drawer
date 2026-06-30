import XCTest
@testable import Orb

final class MoveItemToDrawerServiceIntegrationTests: XCTestCase {
    func testDragItemToDrawerUpdatesPersistence() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-move-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Work"))
        let item = try items.create(Item(type: .text, title: "Drag"))
        try MoveItemToDrawerService(items: items).move(itemID: item.id, toDrawer: drawer.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, drawer.id)
        manager.close()
    }
}
