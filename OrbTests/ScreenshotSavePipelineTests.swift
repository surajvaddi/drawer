import XCTest
@testable import Orb

final class ScreenshotSavePipelineTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var pipeline: ScreenshotSavePipeline!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-shot-save-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        pipeline = ScreenshotSavePipeline(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testSaveCreatesScreenshotItemType() throws {
        let saved = try pipeline.save(imageData: TestFixtures.pngData())
        XCTAssertEqual(saved.type, .screenshot)
    }

    func testThumbnailGeneratedOnSave() throws {
        let saved = try pipeline.save(imageData: TestFixtures.pngData())
        let blobs = try BlobRepository(manager: manager).list(itemId: saved.id)
        XCTAssertTrue(blobs.contains { $0.kind == .thumbnail })
        XCTAssertTrue(blobs.contains { $0.kind == .original })
    }
}
