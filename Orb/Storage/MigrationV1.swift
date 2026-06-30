import Foundation
import SQLite3

struct MigrationV1: DatabaseMigration {
    let version = 1
    let name = "initial_items_and_drawers"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        CREATE TABLE drawers (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT,
          color TEXT,
          parent_drawer_id TEXT,
          description TEXT,
          sort_order INTEGER NOT NULL DEFAULT 0,
          is_pinned INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(parent_drawer_id) REFERENCES drawers(id) ON DELETE SET NULL
        );

        CREATE TABLE items (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          preview TEXT NOT NULL DEFAULT '',
          content_text TEXT,
          content_html TEXT,
          source_url TEXT,
          source_app TEXT,
          source_window_title TEXT,
          original_created_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          last_accessed_at TEXT,
          drawer_id TEXT,
          is_pinned INTEGER NOT NULL DEFAULT 0,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          is_archived INTEGER NOT NULL DEFAULT 0,
          sensitivity TEXT NOT NULL DEFAULT 'normal',
          FOREIGN KEY(drawer_id) REFERENCES drawers(id) ON DELETE SET NULL
        );

        CREATE INDEX idx_items_drawer_id ON items(drawer_id);
        CREATE INDEX idx_items_created_at ON items(created_at DESC);
        CREATE INDEX idx_items_type ON items(type);
        CREATE INDEX idx_drawers_parent_id ON drawers(parent_drawer_id);
        CREATE INDEX idx_drawers_sort_order ON drawers(sort_order);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v1 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
