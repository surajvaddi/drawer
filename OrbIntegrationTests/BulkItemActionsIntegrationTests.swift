import XCTest
@testable import Orb

final class BulkItemActionsIntegrationTests: XCTestCase {
    func testBulkDeleteCleansUpBlobs() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-bulk-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try ScreenshotSavePipeline(coordinator: coordinator).save(imageData: TestFixtures.pngData())
        try BulkItemActions(items: coordinator.items, blobs: BlobRepository(manager: manager), blobStore: coordinator.blobStore)
            .delete(itemIDs: [saved.id])
        XCTAssertTrue(try BlobRepository(manager: manager).list(itemId: saved.id).isEmpty)
        manager.close()
    }
}
