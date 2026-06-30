import XCTest
@testable import Orb

final class BlobRepositoryIntegrationTests: XCTestCase {
    func testBlobMetadataMatchesFilesystemEntry() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-blob-int-\(UUID().uuidString)", isDirectory: true)
        let paths = try StoragePaths(root: root).ensureDirectoriesExist()
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let blobs = BlobRepository(manager: manager)
        let item = try items.create(Item(type: .file, title: "Doc"))
        let data = Data("pdf-content".utf8)
        let fileURL = paths.blobDirectory(for: .original).appendingPathComponent("doc.pdf")
        try data.write(to: fileURL)
        let checksum = BlobRepository.checksum(for: data)
        let blob = try blobs.register(
            Blob(
                itemId: item.id,
                kind: .original,
                localPath: fileURL.path,
                mimeType: "application/pdf",
                sizeBytes: Int64(data.count),
                checksum: checksum
            )
        )
        let diskData = try Data(contentsOf: fileURL)
        XCTAssertEqual(BlobRepository.checksum(for: diskData), blob.checksum)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
