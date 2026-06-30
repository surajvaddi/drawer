import XCTest
@testable import Orb

final class ImageDropPipelineTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var imagePipeline: ImageDropPipeline!
    private var textPipeline: TextDropPipeline!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-img-drop-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        imagePipeline = ImageDropPipeline(screenshotPipeline: ScreenshotSavePipeline(coordinator: coordinator))
        textPipeline = TextDropPipeline(coordinator: coordinator)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testDropPNGCreatesImageItem() throws {
        let saved = try imagePipeline.importPNG(TestFixtures.pngData())
        XCTAssertEqual(saved.type, .screenshot)
    }

    func testDropURLStringCreatesLinkItem() async throws {
        let saved = try await textPipeline.importText("https://example.com/page")
        XCTAssertEqual(saved.type, .url)
    }
}
