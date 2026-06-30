import XCTest
@testable import Orb

final class DocumentTextExtractorIntegrationTests: XCTestCase {
    func testDocumentTextSearchableAfterImport() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-doc-search-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let mdURL = root.appendingPathComponent("notes.md")
        try "# Searchable heading".data(using: .utf8)!.write(to: mdURL)
        let saved = try FileImporter(coordinator: coordinator).importCopy(from: mdURL)
        let text = try DocumentTextExtractor().extract(from: mdURL)
        var updated = saved
        updated.contentText = text
        _ = try coordinator.items.update(updated)
        XCTAssertGreaterThan(try coordinator.ftsRowCount(for: saved.id), 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
