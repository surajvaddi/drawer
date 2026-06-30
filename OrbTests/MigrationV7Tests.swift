import XCTest
import SQLite3
@testable import Orb

final class MigrationV7Tests: XCTestCase {
    func testMigrationAddsPrivateDrawerAndAppSettings() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-mig7-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        XCTAssertEqual(sqlite3_prepare_v2(manager.db, "PRAGMA table_info(drawers);", -1, &stmt, nil), SQLITE_OK)
        var columns: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 1) { columns.append(String(cString: name)) }
        }
        XCTAssertTrue(columns.contains("is_private"))
        sqlite3_finalize(stmt)
        stmt = nil
        XCTAssertEqual(sqlite3_prepare_v2(manager.db, "SELECT name FROM sqlite_master WHERE type='table' AND name='app_settings';", -1, &stmt, nil), SQLITE_OK)
        XCTAssertEqual(sqlite3_step(stmt), SQLITE_ROW)
        manager.close()
    }
}
