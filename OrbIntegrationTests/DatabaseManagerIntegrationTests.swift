import XCTest
@testable import Orb

final class DatabaseManagerIntegrationTests: XCTestCase {
    func testDatabaseManagerCreatesOrbSQLiteFile() throws {
        let tempRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let paths = StoragePaths(root: tempRoot)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        defer { manager.close() }

        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.databaseURL.path))
        XCTAssertEqual(try manager.migrationVersion(), 0)
    }
}
