import XCTest
@testable import Orb

final class PrivateDrawerServiceIntegrationTests: XCTestCase {
    func testPrivateDrawerItemsHiddenUntilUnlocked() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-private-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let items = ItemRepository(manager: manager)
        let privateDrawer = try drawers.create(Drawer(name: "Private", isPrivate: true))
        let secret = try items.create(Item(type: .text, title: "Secret", drawerId: privateDrawer.id))
        let service = PrivateDrawerService(drawers: drawers, isUnlocked: false)
        let visible = service.visibleItems(try items.listRecent(), drawers: try drawers.fetchAll())
        XCTAssertFalse(visible.contains { $0.id == secret.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
