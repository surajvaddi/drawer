import XCTest
@testable import Orb

final class ThumbnailRepairServiceIntegrationTests: XCTestCase {
    func testRepairRunsOnLaunchWhenNeeded() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let stored = try blobStore.write(data: TestFixtures.pngData(), kind: .original, preferredName: "img.png")
        let item = try items.create(Item(type: .image, title: "Img", contentText: ""))
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "image/png", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        let repaired = try ThumbnailRepairService(items: items, blobs: blobs, blobStore: blobStore, generator: ThumbnailGenerator()).repairMissing()
        XCTAssertGreaterThanOrEqual(repaired, 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
