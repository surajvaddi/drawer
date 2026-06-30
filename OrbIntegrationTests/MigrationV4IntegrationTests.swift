import XCTest
import SQLite3
@testable import Orb

final class MigrationV4IntegrationTests: XCTestCase {
    func testMigrationV4FullSchemaPresent() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v4-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        defer {
            manager.close()
            try? FileManager.default.removeItem(at: root)
        }

        try manager.migrate(using: [MigrationV1(), MigrationV2(), MigrationV3(), MigrationV4()])
        XCTAssertEqual(try manager.migrationVersion(), 4)

        let expected = Set([
            "schema_migrations", "drawers", "items", "tags", "item_tags", "blobs",
            "capture_events", "items_fts", "embeddings", "drawer_rules", "ai_annotations"
        ])
        let tables = try listTables(manager: manager)
        for table in expected where table != "items_fts" {
            XCTAssertTrue(tables.contains(table), "missing table \(table)")
        }
        XCTAssertTrue(try hasVirtualTable("items_fts", manager: manager))
    }

    private func listTables(manager: DatabaseManager) throws -> Set<String> {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT name FROM sqlite_master WHERE type='table';", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("list tables failed")
        }
        var names = Set<String>()
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let name = sqlite3_column_text(stmt, 0) {
                names.insert(String(cString: name))
            }
        }
        return names
    }

    private func hasVirtualTable(_ name: String, manager: DatabaseManager) throws -> Bool {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT sql FROM sqlite_master WHERE name='\(name)';"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        guard sqlite3_step(stmt) == SQLITE_ROW, let sqlText = sqlite3_column_text(stmt, 0) else { return false }
        return String(cString: sqlText).contains("USING fts5")
    }
}
