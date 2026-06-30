import XCTest
@testable import Orb

final class BlobRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var items: ItemRepository!
    private var blobs: BlobRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-blob-repo-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        items = ItemRepository(manager: manager)
        blobs = BlobRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testRegisterBlobStoresChecksum() throws {
        let item = try items.create(Item(type: .image, title: "Shot"))
        let data = Data("image-bytes".utf8)
        let checksum = BlobRepository.checksum(for: data)
        let blob = Blob(
            itemId: item.id,
            kind: .original,
            localPath: "/tmp/test.png",
            mimeType: "image/png",
            sizeBytes: Int64(data.count),
            checksum: checksum
        )
        let saved = try blobs.register(blob)
        XCTAssertEqual(saved.checksum, checksum)
    }

    func testListBlobsByItemAndKind() throws {
        let item = try items.create(Item(type: .screenshot, title: "UI"))
        _ = try blobs.register(Blob(itemId: item.id, kind: .original, localPath: "/a.png", mimeType: "image/png", sizeBytes: 1, checksum: "a"))
        _ = try blobs.register(Blob(itemId: item.id, kind: .thumbnail, localPath: "/a-thumb.png", mimeType: "image/png", sizeBytes: 1, checksum: "b"))
        XCTAssertEqual(try blobs.list(itemId: item.id).count, 2)
        XCTAssertEqual(try blobs.list(itemId: item.id, kind: .thumbnail).count, 1)
    }
}
