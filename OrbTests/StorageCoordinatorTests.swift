import XCTest
@testable import Orb

final class StorageCoordinatorTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var coordinator: StorageCoordinator!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-coordinator-\(UUID().uuidString)", isDirectory: true)
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

    func testCommitOnSuccessUpdatesFTS() throws {
        let saved = try coordinator.saveTextItem(
            StorageCoordinator.SaveTextItemRequest(
                item: Item(type: .text, title: "FTS Item", contentText: "searchable content")
            )
        )
        XCTAssertEqual(try coordinator.ftsRowCount(for: saved.id), 1)
    }

    func testRollbackOnDBFailureLeavesNoOrphanBlob() throws {
        let blobCountBefore = try FileManager.default.contentsOfDirectory(
            at: paths.blobDirectory(for: .original),
            includingPropertiesForKeys: nil
        ).count
        let broken = StorageCoordinator(paths: paths, manager: manager, blobs: FailingBlobRegistrar())
        XCTAssertThrowsError(
            try broken.saveTextItem(
                StorageCoordinator.SaveTextItemRequest(
                    item: Item(type: .file, title: "Broken"),
                    blobData: Data("orphan-test".utf8),
                    mimeType: "application/octet-stream"
                )
            )
        )
        let blobCountAfter = try FileManager.default.contentsOfDirectory(
            at: paths.blobDirectory(for: .original),
            includingPropertiesForKeys: nil
        ).count
        XCTAssertEqual(blobCountBefore, blobCountAfter)
    }
}

private struct FailingBlobRegistrar: BlobRegistering {
    func register(_ blob: Blob) throws -> Blob {
        throw OrbError.storage("forced blob failure")
    }
}
