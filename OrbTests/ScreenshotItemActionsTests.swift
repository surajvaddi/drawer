import XCTest
@testable import Orb

final class ScreenshotItemActionsTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var coordinator: StorageCoordinator!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-shot-actions-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        coordinator = StorageCoordinator(paths: paths, manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testCopyImageWritesPNGToPasteboard() throws {
        let saved = try ScreenshotSavePipeline(coordinator: coordinator).save(imageData: TestFixtures.pngData())
        let pasteboard = MockPasteboard()
        let actions = ScreenshotItemActions(
            pasteboard: pasteboard,
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager)
        )
        try actions.copyImage(itemID: saved.id)
        XCTAssertNotNil(pasteboard.data(forType: .png))
    }

    func testCopyOCRTextWritesString() {
        let pasteboard = MockPasteboard()
        let actions = ScreenshotItemActions(
            pasteboard: pasteboard,
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager)
        )
        actions.copyOCRText("recognized text")
        XCTAssertEqual(pasteboard.string(forType: .string), "recognized text")
    }
}
