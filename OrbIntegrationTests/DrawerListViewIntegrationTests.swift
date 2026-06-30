import XCTest
@testable import Orb

final class DrawerListViewIntegrationTests: XCTestCase {
    func testSelectingDrawerShowsItsItems() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drawer-list-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let research = try drawers.create(Drawer(name: "Research", sortOrder: 0))
        var item = Item(type: .text, title: "Concrete", preview: "notes", drawerId: research.id)
        item = try ItemRepository(manager: manager).create(item)
        let model = DrawerViewModel(
            items: try ItemRepository(manager: manager).listRecent(),
            drawers: try drawers.fetchAll(),
            selectedDrawerID: research.id
        )
        XCTAssertEqual(model.items(for: research.id).first?.id, item.id)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
