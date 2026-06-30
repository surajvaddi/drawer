import XCTest
@testable import Orb

final class BlobStoreTests: XCTestCase {
    private var paths: StoragePaths!
    private var store: BlobStore!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-blob-store-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        store = BlobStore(paths: paths)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testWriteBlobCreatesFile() throws {
        let data = Data("hello blob".utf8)
        let stored = try store.write(data: data, preferredName: "test.bin")
        XCTAssertTrue(FileManager.default.fileExists(atPath: stored.path))
        XCTAssertEqual(try store.read(path: stored.path), data)
    }

    func testChecksumStableForSameContent() throws {
        let data = Data(repeating: 0xAB, count: 64)
        let a = try store.write(data: data, preferredName: "a.bin")
        let b = try store.write(data: data, preferredName: "b.bin")
        XCTAssertEqual(a.checksum, b.checksum)
    }
}
