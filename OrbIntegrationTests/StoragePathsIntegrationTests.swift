import XCTest
@testable import Orb

final class StoragePathsIntegrationTests: XCTestCase {
    func testStoragePathsCreatesRealDirectoriesInTempHome() throws {
        let tempHome = FileManager.default.temporaryDirectory
            .appendingPathComponent("OrbHome-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempHome, withIntermediateDirectories: true)

        let orbRoot = tempHome.appendingPathComponent("Library/Application Support/Orb", isDirectory: true)
        let paths = try StoragePaths(root: orbRoot).ensureDirectoriesExist()

        for kind in BlobKind.allCases {
            XCTAssertTrue(FileManager.default.fileExists(atPath: paths.blobDirectory(for: kind).path))
        }
    }
}
