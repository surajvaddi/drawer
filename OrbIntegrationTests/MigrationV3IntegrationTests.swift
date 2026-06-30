import XCTest
import SQLite3
@testable import Orb

final class MigrationV3IntegrationTests: XCTestCase {
    func testFTSIndexesItemOnInsert() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v3-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        defer {
            manager.close()
            try? FileManager.default.removeItem(at: root)
        }

        try manager.migrate(using: [MigrationV1(), MigrationV2(), MigrationV3()])
        let now = ISO8601DateFormatter().string(from: Date())
        try manager.exec(
            """
            INSERT INTO items(id, type, title, preview, content_text, created_at, updated_at)
            VALUES ('item-fts', 'text', 'Kind Designs', 'living seawalls', 'concrete sensors', '\(now)', '\(now)');
            """
        )

        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT item_id FROM items_fts WHERE items_fts MATCH 'seawalls';", -1, &stmt, nil) == SQLITE_OK else {
            XCTFail("fts query prepare failed")
            return
        }
        XCTAssertEqual(sqlite3_step(stmt), SQLITE_ROW)
        if let itemID = sqlite3_column_text(stmt, 0) {
            XCTAssertEqual(String(cString: itemID), "item-fts")
        } else {
            XCTFail("missing fts row")
        }
    }
}
