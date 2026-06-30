import XCTest
@testable import Orb

final class OCRIndexerTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var coordinator: StorageCoordinator!
    private var indexer: OCRIndexer!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ocr-index-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        coordinator = StorageCoordinator(paths: paths, manager: manager)
        indexer = OCRIndexer(coordinator: coordinator, ocrService: StubOCRService(text: "invoice number 42"))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testOCRTextIndexedForSearch() throws {
        let item = try coordinator.items.create(Item(type: .screenshot, title: "Shot", preview: "Screenshot"))
        let updated = try indexer.index(item: item, imageData: TestFixtures.pngData())
        let ids = try indexer.searchIndexedText(manager: manager, query: "invoice")
        XCTAssertTrue(ids.contains(updated.id))
    }

    func testOCRBlobLinkedToItem() throws {
        let item = try coordinator.items.create(Item(type: .screenshot, title: "Shot", preview: "Screenshot"))
        _ = try indexer.index(item: item, imageData: TestFixtures.pngData())
        let blobs = try BlobRepository(manager: manager).list(itemId: item.id, kind: .ocr)
        XCTAssertEqual(blobs.count, 1)
    }
}

private struct StubOCRService: OCRRecognizing {
    let text: String
    func recognizeText(in imageData: Data) throws -> String { text }
}
