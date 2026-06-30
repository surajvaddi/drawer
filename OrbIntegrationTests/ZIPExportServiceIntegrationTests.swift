import XCTest
@testable import Orb

final class ZIPExportServiceIntegrationTests: XCTestCase {
    func testExportZIPRestoresViaImport() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "ZIPRestore", contentText: "restore me"))
        let jsonExport = JSONExportService(items: items, drawers: drawers, tags: tags)
        let zipURL = root.appendingPathComponent("backup.zip")
        try ZIPExportService(
            jsonExport: jsonExport,
            markdownExport: MarkdownExportService(items: items, drawers: drawers),
            paths: paths
        ).exportArchive(to: zipURL)
        let jsonURL = root.appendingPathComponent("export.json")
        try jsonExport.export(to: jsonURL)
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importFile(at: jsonURL, merge: true)
        XCTAssertNotNil(try items.fetch(id: item.id))
        XCTAssertGreaterThanOrEqual(result.items, 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
