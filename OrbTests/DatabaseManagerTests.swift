import XCTest
@testable import Orb

final class DatabaseManagerTests: XCTestCase {
    private var tempRoot: URL!
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        tempRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        manager = DatabaseManager(paths: StoragePaths(root: tempRoot))
        try manager.open()
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testMigrationVersionStartsAtZero() throws {
        XCTAssertEqual(try manager.migrationVersion(), 0)
    }

    func testMigrationsAreIdempotent() throws {
        struct TestMigration: DatabaseMigration {
            let version = 1
            let name = "test"
            func apply(on db: OpaquePointer) throws {
                _ = db
            }
        }
        let migration = TestMigration()
        try manager.migrate(using: [migration])
        XCTAssertEqual(try manager.migrationVersion(), 1)
        try manager.migrate(using: [migration])
        XCTAssertEqual(try manager.migrationVersion(), 1)
    }
}
