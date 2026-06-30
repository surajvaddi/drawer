import XCTest
@testable import Orb

final class DrawerStyleEditorIntegrationTests: XCTestCase {
    func testDrawerStyleRendersInList() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-style-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let editor = DrawerStyleEditor(drawers: drawers)
        let drawer = try drawers.create(Drawer(name: "Design", icon: "paintbrush", color: "#111111"))
        let style = editor.style(for: drawer)
        XCTAssertEqual(style.icon, "paintbrush")
        manager.close()
    }
}
