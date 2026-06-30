import XCTest
@testable import Orb

final class ScreenshotItemActionsIntegrationTests: XCTestCase {
    func testScreenshotActionsEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-shot-actions-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try ScreenshotSavePipeline(coordinator: coordinator).save(imageData: TestFixtures.pngData())
        let pasteboard = MockPasteboard()
        let actions = ScreenshotItemActions(
            pasteboard: pasteboard,
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager)
        )
        try actions.copyImage(itemID: saved.id)
        XCTAssertNotNil(pasteboard.data(forType: .png))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
