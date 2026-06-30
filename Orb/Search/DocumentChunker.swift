import Foundation
import SQLite3

struct DocumentChunk: Identifiable, Equatable, Sendable {
    var id: String
    var itemId: String
    var chunkIndex: Int
    var text: String
    var embeddingId: String?

    init(
        id: String = UUID().uuidString,
        itemId: String,
        chunkIndex: Int,
        text: String,
        embeddingId: String? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.chunkIndex = chunkIndex
        self.text = text
        self.embeddingId = embeddingId
    }
}

struct DocumentChunker: Sendable {
    let manager: DatabaseManager
    let maxChunkLength: Int

    init(manager: DatabaseManager, maxChunkLength: Int = 500) {
        self.manager = manager
        self.maxChunkLength = maxChunkLength
    }

    func chunk(itemId: String, text: String) throws -> [DocumentChunk] {
        try manager.exec("DELETE FROM document_chunks WHERE item_id='\(escape(itemId))';")
        let parts = split(text)
        var chunks: [DocumentChunk] = []
        for (index, part) in parts.enumerated() {
            let chunk = DocumentChunk(itemId: itemId, chunkIndex: index, text: part)
            try manager.exec(
                """
                INSERT INTO document_chunks(id, item_id, chunk_index, text, embedding_id)
                VALUES (
                  '\(escape(chunk.id))',
                  '\(escape(itemId))',
                  \(index),
                  '\(escape(part))',
                  NULL
                );
                """
            )
            chunks.append(chunk)
        }
        return chunks
    }

    func fetch(itemId: String) throws -> [DocumentChunk] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT id, item_id, chunk_index, text, embedding_id FROM document_chunks WHERE item_id = ? ORDER BY chunk_index ASC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch document chunks failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        var rows: [DocumentChunk] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            func text(_ index: Int32) -> String? {
                guard let c = sqlite3_column_text(stmt, index) else { return nil }
                return String(cString: c)
            }
            guard let id = text(0), let itemId = text(1), let chunkText = text(3) else { continue }
            rows.append(DocumentChunk(
                id: id,
                itemId: itemId,
                chunkIndex: Int(sqlite3_column_int(stmt, 2)),
                text: chunkText,
                embeddingId: text(4)
            ))
        }
        return rows
    }

    private func split(_ text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        var chunks: [String] = []
        var start = trimmed.startIndex
        while start < trimmed.endIndex {
            let end = trimmed.index(start, offsetBy: maxChunkLength, limitedBy: trimmed.endIndex) ?? trimmed.endIndex
            chunks.append(String(trimmed[start..<end]))
            start = end
        }
        return chunks
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
