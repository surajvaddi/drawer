import XCTest
@testable import Orb

final class OCRServiceIntegrationTests: XCTestCase {
    func testOCROnSavedScreenshotBlob() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ocr-blob-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try ScreenshotSavePipeline(coordinator: coordinator).save(imageData: TestFixtures.pngData())
        let blob = try BlobRepository(manager: manager).list(itemId: saved.id, kind: .original).first!
        let text = try OCRService().recognizeText(in: try coordinator.blobStore.read(path: blob.localPath))
        XCTAssertNotNil(text)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
