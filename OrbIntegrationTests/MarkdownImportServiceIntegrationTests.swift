import XCTest
@testable import Orb

final class MarkdownImportServiceIntegrationTests: XCTestCase {
    func testImportBookmarksFolder() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(
            drawers: DrawerRepository(manager: manager),
            defaults: UserDefaults(suiteName: "orb.md-import.int.\(UUID().uuidString)")!
        ).seedIfNeeded()
        let items = ItemRepository(manager: manager)
        let mdURL = root.appendingPathComponent("import.md")
        let md = "# Orb Export\n\n## Bookmark Note\n\n- Source: https://example.com\n\nSaved link content"
        try md.write(to: mdURL, atomically: true, encoding: .utf8)
        let imported = try MarkdownImportService(items: items).importFile(at: mdURL)
        XCTAssertFalse(imported.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
