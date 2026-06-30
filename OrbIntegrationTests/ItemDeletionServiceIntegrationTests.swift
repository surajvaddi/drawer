import XCTest
@testable import Orb

final class ItemDeletionServiceIntegrationTests: XCTestCase {
    func testDeleteItemFullyCleanup() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "FullDelete", contentText: "cleanup"))
        let stored = try BlobStore(paths: paths).write(data: Data("x".utf8), kind: .original, preferredName: "x.txt")
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "text/plain", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: AIAnnotationRepository(manager: manager), blobStore: BlobStore(paths: paths)).delete(itemID: item.id)
        XCTAssertNil(try items.fetch(id: item.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
