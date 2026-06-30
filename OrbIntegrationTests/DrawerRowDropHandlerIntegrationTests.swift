import XCTest
@testable import Orb

final class DrawerRowDropHandlerIntegrationTests: XCTestCase {
    func testDragBetweenDrawersPersists() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drag-drawer-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let source = try drawers.create(Drawer(name: "Source"))
        let target = try drawers.create(Drawer(name: "Target"))
        let item = try items.create(Item(type: .text, title: "Move", drawerId: source.id))
        try DrawerRowDropHandler(moveService: MoveItemToDrawerService(items: items)).drop(itemID: item.id, onDrawer: target.id)
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, target.id)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
