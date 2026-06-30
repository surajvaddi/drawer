import XCTest
@testable import Orb

final class MigrationV4Tests: XCTestCase {
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-migration-v4-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: [MigrationV1(), MigrationV2(), MigrationV3(), MigrationV4()])
        let now = ISO8601DateFormatter().string(from: Date())
        try manager.exec(
            """
            INSERT INTO drawers(id, name, sort_order, created_at, updated_at)
            VALUES ('drawer-1', 'Jobs', 0, '\(now)', '\(now)');
            INSERT INTO items(id, type, title, created_at, updated_at)
            VALUES ('item-1', 'text', 'Test', '\(now)', '\(now)');
            """
        )
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testDrawerRuleJSONColumnRoundTrip() throws {
        let json = #"{"url_contains":"greenhouse.io"}"#
        try manager.exec(
            """
            INSERT INTO drawer_rules(id, drawer_id, name, condition_json, priority)
            VALUES ('rule-1', 'drawer-1', 'Jobs URL', '\(json)', 10);
            """
        )
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT condition_json FROM drawer_rules WHERE id='rule-1';", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("select failed")
        }
        guard sqlite3_step(stmt) == SQLITE_ROW, let text = sqlite3_column_text(stmt, 0) else {
            XCTFail("missing row")
            return
        }
        XCTAssertEqual(String(cString: text), json)
    }
}

import SQLite3
