import XCTest
@testable import Orb

final class ItemDeletionServiceTests: XCTestCase {
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

    func testDeleteRemovesAllAssociatedRecords() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let annotations = AIAnnotationRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Delete", contentText: "x"))
        _ = try annotations.upsert(AIAnnotation(itemId: item.id, kind: .title, model: "m", content: ["value": "t"]))
        let stored = try BlobStore(paths: paths).write(data: Data("blob".utf8), kind: .original, preferredName: "f.txt")
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: stored.path, mimeType: "text/plain", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: annotations, blobStore: BlobStore(paths: paths)).delete(itemID: item.id)
        XCTAssertNil(try items.fetch(id: item.id))
        XCTAssertTrue(try blobs.list(itemId: item.id).isEmpty)
        XCTAssertTrue(try annotations.fetchAll(itemId: item.id).isEmpty)
    }

    func testDeleteRemovesFilesystemBlobs() throws {
        let paths = StoragePaths(root: root)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let blobStore = BlobStore(paths: paths)
        let item = try items.create(Item(type: .file, title: "File", contentText: ""))
        let stored = try blobStore.write(data: Data("filedata".utf8), kind: .original, preferredName: "file.bin")
        let path = stored.path
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: path, mimeType: "application/octet-stream", sizeBytes: stored.sizeBytes, checksum: stored.checksum))
        try ItemDeletionService(items: items, blobs: blobs, annotations: AIAnnotationRepository(manager: manager), blobStore: blobStore).delete(itemID: item.id)
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
    }
}
