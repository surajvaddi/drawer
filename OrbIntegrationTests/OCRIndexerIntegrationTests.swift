import XCTest
@testable import Orb

final class OCRIndexerIntegrationTests: XCTestCase {
    func testSearchFindsScreenshotByOCRText() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ocr-search-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let item = try coordinator.items.create(Item(type: .screenshot, title: "Shot", preview: "Screenshot"))
        let indexer = OCRIndexer(coordinator: coordinator, ocrService: StubOCRService(text: "unique-token-123"))
        let updated = try indexer.index(item: item, imageData: TestFixtures.pngData())
        let ids = try indexer.searchIndexedText(manager: manager, query: "unique-token-123")
        XCTAssertTrue(ids.contains(updated.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}

private struct StubOCRService: OCRRecognizing {
    let text: String
    func recognizeText(in imageData: Data) throws -> String { text }
}
