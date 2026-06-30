import XCTest
@testable import Orb

final class BlobStoreIntegrationTests: XCTestCase {
    func testBlobStoreUsesApplicationSupportDirectory() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-blob-store-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let store = BlobStore(paths: paths)
        let stored = try store.write(data: Data("integration".utf8), preferredName: "int.bin")
        XCTAssertTrue(stored.path.contains(paths.blobDirectory(for: .original).path))
        try? FileManager.default.removeItem(at: root)
    }
}
