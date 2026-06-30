import XCTest
@testable import Orb

final class DrawerStyleEditorTests: XCTestCase {
    private var manager: DatabaseManager!
    private var editor: DrawerStyleEditor!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-style-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        editor = DrawerStyleEditor(drawers: DrawerRepository(manager: manager))
    }

    override func tearDownWithError() throws { manager.close() }

    func testDrawerColorHexRoundTrip() throws {
        let drawer = try DrawerRepository(manager: manager).create(Drawer(name: "Styled", color: "abc123"))
        let style = editor.style(for: drawer)
        let updated = try editor.apply(style: DrawerStyle(icon: "folder", iconType: .sfSymbol, colorHex: style.colorHex), to: drawer)
        XCTAssertEqual(updated.color, "#ABC123")
    }

    func testIconTypePersists() throws {
        let drawer = Drawer(name: "Emoji", icon: "📁")
        let style = editor.style(for: drawer)
        XCTAssertEqual(style.iconType, .emoji)
    }
}
