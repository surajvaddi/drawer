import XCTest
import SQLite3
@testable import Orb

final class MigrationV6Tests: XCTestCase {
    func testMigrationAddsSourceItemId() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-mig6-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        XCTAssertEqual(sqlite3_prepare_v2(manager.db, "PRAGMA table_info(items);", -1, &stmt, nil), SQLITE_OK)
        var columns: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 1) { columns.append(String(cString: name)) }
        }
        XCTAssertTrue(columns.contains("source_item_id"))
        manager.close()
    }
}
