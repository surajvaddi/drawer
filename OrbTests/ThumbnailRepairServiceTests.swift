import XCTest
@testable import Orb

final class ThumbnailRepairServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testRepairCreatesMissingThumbnail() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let png = TestFixtures.pngData()
        let stored = try blobStore.write(data: png, kind: .original, preferredName: "shot.png")
        let item = try items.create(Item(type: .screenshot, title: "Shot", contentText: "ocr"))
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "image/png", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        let service = ThumbnailRepairService(items: items, blobs: blobs, blobStore: blobStore, generator: ThumbnailGenerator())
        let repaired = try service.repairMissing()
        XCTAssertGreaterThanOrEqual(repaired, 1)
    }
}
