import XCTest
@testable import Orb

final class ItemReorderControllerIntegrationTests: XCTestCase {
    func testDragItemIntoDifferentDrawer() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-move-drawer-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Work", icon: "folder", color: "#000000"))
        let repository = ItemRepository(manager: manager)
        let controller = ItemReorderController(repository: repository)
        let saved = try repository.create(Item(type: .text, title: "Move me"))
        try controller.move(itemID: saved.id, toDrawer: drawer.id)
        let items = try repository.listByDrawer(drawer.id)
        XCTAssertTrue(items.contains { $0.id == saved.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
