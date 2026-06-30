import XCTest
@testable import Orb

final class MigrationV2IntegrationTests: XCTestCase {
    func testMigrationV2UpgradesFromV1() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v2-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        defer {
            manager.close()
            try? FileManager.default.removeItem(at: paths.root)
        }

        try manager.migrate(using: [MigrationV1()])
        XCTAssertEqual(try manager.migrationVersion(), 1)
        try manager.migrate(using: [MigrationV2()])
        XCTAssertEqual(try manager.migrationVersion(), 2)

        let tables = try tableNames(manager: manager)
        XCTAssertTrue(tables.contains("tags"))
        XCTAssertTrue(tables.contains("item_tags"))
        XCTAssertTrue(tables.contains("blobs"))
        XCTAssertTrue(tables.contains("capture_events"))
    }

    private func tableNames(manager: DatabaseManager) throws -> Set<String> {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT name FROM sqlite_master WHERE type='table';", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("failed to list tables")
        }
        var names = Set<String>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 0) {
                names.insert(String(cString: name))
            }
        }
        return names
    }
}

import SQLite3
