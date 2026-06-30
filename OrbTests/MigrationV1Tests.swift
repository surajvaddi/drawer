import XCTest
@testable import Orb

final class MigrationV1Tests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v1-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testItemsTableSchemaMatchesModel() throws {
        try manager.migrate(using: [MigrationV1()])
        let columns = try tableColumns("items")
        XCTAssertTrue(columns.contains("id"))
        XCTAssertTrue(columns.contains("type"))
        XCTAssertTrue(columns.contains("title"))
        XCTAssertTrue(columns.contains("preview"))
        XCTAssertTrue(columns.contains("content_text"))
        XCTAssertTrue(columns.contains("drawer_id"))
        XCTAssertTrue(columns.contains("sensitivity"))
    }

    func testDrawersTableSupportsParentID() throws {
        try manager.migrate(using: [MigrationV1()])
        let columns = try tableColumns("drawers")
        XCTAssertTrue(columns.contains("parent_drawer_id"))
    }

    private func tableColumns(_ table: String) throws -> Set<String> {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "PRAGMA table_info(\(table));"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("pragma failed")
        }
        var columns = Set<String>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 1) {
                columns.insert(String(cString: name))
            }
        }
        return columns
    }
}

import SQLite3
