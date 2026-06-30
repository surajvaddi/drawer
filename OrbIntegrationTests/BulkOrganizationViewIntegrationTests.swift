import XCTest
@testable import Orb

final class BulkOrganizationViewIntegrationTests: XCTestCase {
    func testBulkOrganizationEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Bulk", sortOrder: 50))
        let a = try items.create(Item(type: .text, title: "A", contentText: "a"))
        let b = try items.create(Item(type: .text, title: "B", contentText: "b"))
        let ids: Set<String> = [a.id, b.id]
        for id in ids { try MoveItemToDrawerService(items: items).move(itemID: id, toDrawer: drawer.id) }
        XCTAssertEqual(try items.fetch(id: a.id)?.drawerId, drawer.id)
        XCTAssertEqual(try items.fetch(id: b.id)?.drawerId, drawer.id)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
