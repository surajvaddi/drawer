import Foundation
import SQLite3

struct MigrationV3: DatabaseMigration {
    let version = 3
    let name = "fts_and_embeddings"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        CREATE VIRTUAL TABLE items_fts USING fts5(
          item_id UNINDEXED,
          title,
          preview,
          content_text,
          source_url,
          tokenize = 'porter unicode61'
        );

        CREATE TRIGGER items_fts_insert AFTER INSERT ON items BEGIN
          INSERT INTO items_fts(item_id, title, preview, content_text, source_url)
          VALUES (new.id, new.title, new.preview, COALESCE(new.content_text, ''), COALESCE(new.source_url, ''));
        END;

        CREATE TRIGGER items_fts_delete AFTER DELETE ON items BEGIN
          DELETE FROM items_fts WHERE item_id = old.id;
        END;

        CREATE TRIGGER items_fts_update AFTER UPDATE ON items BEGIN
          DELETE FROM items_fts WHERE item_id = old.id;
          INSERT INTO items_fts(item_id, title, preview, content_text, source_url)
          VALUES (new.id, new.title, new.preview, COALESCE(new.content_text, ''), COALESCE(new.source_url, ''));
        END;

        CREATE TABLE embeddings (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          model TEXT NOT NULL,
          vector_json TEXT NOT NULL,
          text_hash TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );

        CREATE INDEX idx_embeddings_item_id ON embeddings(item_id);
        CREATE INDEX idx_embeddings_text_hash ON embeddings(text_hash);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v3 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
