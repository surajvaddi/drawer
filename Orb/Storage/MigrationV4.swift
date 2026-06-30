import Foundation
import SQLite3

struct MigrationV4: DatabaseMigration {
    let version = 4
    let name = "drawer_rules_and_ai_annotations"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        CREATE TABLE drawer_rules (
          id TEXT PRIMARY KEY,
          drawer_id TEXT NOT NULL,
          name TEXT NOT NULL,
          condition_json TEXT NOT NULL,
          priority INTEGER NOT NULL DEFAULT 0,
          enabled INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY(drawer_id) REFERENCES drawers(id) ON DELETE CASCADE
        );

        CREATE TABLE ai_annotations (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          kind TEXT NOT NULL,
          model TEXT NOT NULL,
          content_json TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );

        CREATE INDEX idx_drawer_rules_drawer_id ON drawer_rules(drawer_id);
        CREATE INDEX idx_drawer_rules_priority ON drawer_rules(priority DESC);
        CREATE INDEX idx_ai_annotations_item_id ON ai_annotations(item_id);
        CREATE INDEX idx_ai_annotations_kind ON ai_annotations(kind);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v4 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
