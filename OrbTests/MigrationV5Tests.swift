import XCTest
import SQLite3
@testable import Orb

final class MigrationV5Tests: XCTestCase {
    func testMigrationAddsUserNoteAndSortOrder() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-mig5-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: [MigrationV1(), MigrationV2(), MigrationV3(), MigrationV4(), MigrationV5()])
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        XCTAssertEqual(sqlite3_prepare_v2(manager.db, "PRAGMA table_info(items);", -1, &stmt, nil), SQLITE_OK)
        var columns: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 1) {
                columns.append(String(cString: name))
            }
        }
        XCTAssertTrue(columns.contains("user_note"))
        XCTAssertTrue(columns.contains("sort_order"))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
