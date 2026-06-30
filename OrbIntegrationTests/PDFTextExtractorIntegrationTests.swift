import XCTest
@testable import Orb

final class PDFTextExtractorIntegrationTests: XCTestCase {
    func testPDFItemGetsSearchableText() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-pdf-fts-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let pdfURL = root.appendingPathComponent("doc.pdf")
        try TestFixtures.minimalPDFData().write(to: pdfURL)
        let saved = try FileImporter(coordinator: coordinator).importCopy(from: pdfURL)
        let text = try PDFTextExtractor().extract(from: TestFixtures.minimalPDFData()).text
        var updated = saved
        updated.contentText = text
        _ = try coordinator.items.update(updated)
        XCTAssertGreaterThan(try coordinator.ftsRowCount(for: saved.id), 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
