import Foundation
import SQLite3

struct MigrationV2: DatabaseMigration {
    let version = 2
    let name = "tags_blobs_capture_events"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        CREATE TABLE tags (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
          color TEXT
        );

        CREATE TABLE item_tags (
          item_id TEXT NOT NULL,
          tag_id TEXT NOT NULL,
          PRIMARY KEY (item_id, tag_id),
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE,
          FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE
        );

        CREATE TABLE blobs (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          kind TEXT NOT NULL,
          local_path TEXT NOT NULL,
          mime_type TEXT NOT NULL,
          size_bytes INTEGER NOT NULL,
          checksum TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );

        CREATE TABLE capture_events (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          method TEXT NOT NULL,
          source_app TEXT,
          pasteboard_types TEXT,
          raw_metadata TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );

        CREATE INDEX idx_blobs_item_id ON blobs(item_id);
        CREATE INDEX idx_capture_events_item_id ON capture_events(item_id);
        CREATE INDEX idx_item_tags_tag_id ON item_tags(tag_id);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v2 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
