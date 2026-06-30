import XCTest
@testable import Orb

final class MigrationV1IntegrationTests: XCTestCase {
    func testMigrationV1AppliesOnFreshDatabase() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v1-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        defer {
            manager.close()
            try? FileManager.default.removeItem(at: paths.root)
        }

        XCTAssertEqual(try manager.migrationVersion(), 0)
        try manager.migrate(using: [MigrationV1()])
        XCTAssertEqual(try manager.migrationVersion(), 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: paths.databaseURL.path))
    }
}
