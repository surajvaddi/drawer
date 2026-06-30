import Foundation
import SQLite3

struct MigrationV8: DatabaseMigration {
    let version = 8
    let name = "ai_jobs_and_document_chunks"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        CREATE TABLE ai_jobs (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          kind TEXT NOT NULL,
          status TEXT NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );
        CREATE INDEX idx_ai_jobs_status ON ai_jobs(status);
        CREATE TABLE document_chunks (
          id TEXT PRIMARY KEY,
          item_id TEXT NOT NULL,
          chunk_index INTEGER NOT NULL,
          text TEXT NOT NULL,
          embedding_id TEXT,
          FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
        );
        CREATE INDEX idx_document_chunks_item_id ON document_chunks(item_id);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v8 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
