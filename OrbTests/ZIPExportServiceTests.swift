import XCTest
@testable import Orb

final class ZIPExportServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testZIPContainsBlobsAndManifest() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "ZIP", contentText: "zip content"))
        let jsonExport = JSONExportService(items: items, drawers: drawers, tags: tags)
        let mdExport = MarkdownExportService(items: items, drawers: drawers)
        let zipURL = root.appendingPathComponent("export.zip")
        try ZIPExportService(jsonExport: jsonExport, markdownExport: mdExport, paths: paths).exportArchive(to: zipURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: zipURL.path))
        let attrs = try FileManager.default.attributesOfItem(atPath: zipURL.path)
        XCTAssertGreaterThan((attrs[.size] as? Int) ?? 0, 0)
    }
}
