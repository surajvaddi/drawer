import XCTest
@testable import Orb

final class ExportImportViewIntegrationTests: XCTestCase {
    func testManualBackupAndRestoreFlow() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Backup", contentText: "important"))
        let jsonURL = root.appendingPathComponent("backup.json")
        try JSONExportService(items: items, drawers: drawers, tags: tags).export(to: jsonURL)
        try manager.exec("DELETE FROM items;")
        _ = try JSONImportService(items: items, drawers: drawers, tags: tags).importFile(at: jsonURL, merge: false)
        XCTAssertNotNil(try items.fetch(id: item.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
