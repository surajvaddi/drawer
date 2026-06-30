import Foundation
import SQLite3

struct IndexRebuildService: Sendable {
    let manager: DatabaseManager
    let indexer: EmbeddingIndexer

    func rebuildFTS() throws -> Int {
        try manager.exec("DELETE FROM items_fts;")
        try manager.exec(
            """
            INSERT INTO items_fts(item_id, title, preview, content_text, source_url)
            SELECT id, title, preview, COALESCE(content_text, ''), COALESCE(source_url, '')
            FROM items;
            """
        )
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT COUNT(*) FROM items_fts;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fts rebuild count failed")
        }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }

    func rebuildEmbeddings(limit: Int = 100) async throws -> Int {
        try await indexer.indexAll(limit: limit)
    }
}
