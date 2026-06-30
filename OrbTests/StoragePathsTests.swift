import XCTest
@testable import Orb

final class StoragePathsTests: XCTestCase {
    func testStoragePathsCreatesSubdirectories() throws {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let paths = try StoragePaths(root: temp).ensureDirectoriesExist()

        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.root.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.blobsURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.indexesURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.backupsURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.logsURL.path))
    }

    func testBlobPathsForEachKind() {
        let paths = StoragePaths(root: URL(fileURLWithPath: "/tmp/OrbTest"))
        XCTAssertEqual(paths.blobDirectory(for: .original).lastPathComponent, "originals")
        XCTAssertEqual(paths.blobDirectory(for: .thumbnail).lastPathComponent, "thumbnails")
        XCTAssertEqual(paths.blobDirectory(for: .embedding).lastPathComponent, "vector")
    }
}
