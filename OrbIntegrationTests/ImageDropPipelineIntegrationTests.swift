import XCTest
@testable import Orb

final class ImageDropPipelineIntegrationTests: XCTestCase {
    func testDropImageOnOrbGeneratesThumbnail() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drop-img-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try ImageDropPipeline(screenshotPipeline: ScreenshotSavePipeline(coordinator: coordinator)).importPNG(TestFixtures.pngData())
        let blobs = try BlobRepository(manager: manager).list(itemId: saved.id)
        XCTAssertTrue(blobs.contains { $0.kind == .thumbnail })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
