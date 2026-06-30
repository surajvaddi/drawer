import Foundation
import SQLite3

protocol EmbeddingProvider: Sendable {
    var modelName: String { get }
    func embed(text: String) async throws -> [Double]
}

struct MockEmbeddingProvider: EmbeddingProvider {
    let modelName = "mock-embed-v1"
    private let aiProvider = MockAIProvider()

    func embed(text: String) async throws -> [Double] {
        try await aiProvider.embed(text: text)
    }
}

struct StoredEmbeddingRepository: Sendable {
    let manager: DatabaseManager

    func save(_ embedding: Embedding) throws {
        let vectorJSON = try encodeVector(embedding.vector)
        try manager.exec(
            """
            INSERT INTO embeddings(id, item_id, model, vector_json, text_hash, created_at)
            VALUES (
              '\(escape(embedding.id))',
              '\(escape(embedding.itemId))',
              '\(escape(embedding.model))',
              '\(escape(vectorJSON))',
              '\(escape(embedding.textHash))',
              '\(DBDateCodec.string(from: embedding.createdAt))'
            )
            ON CONFLICT(id) DO UPDATE SET
              vector_json='\(escape(vectorJSON))',
              text_hash='\(escape(embedding.textHash))';
            """
        )
    }

    func fetch(itemId: String, model: String) throws -> Embedding? {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT id, item_id, model, vector_json, text_hash, created_at FROM embeddings WHERE item_id = ? AND model = ? LIMIT 1;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch embedding failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, model, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return try mapRow(stmt)
    }

    func listAll(model: String) throws -> [Embedding] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT id, item_id, model, vector_json, text_hash, created_at FROM embeddings WHERE model = ?;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list embeddings failed")
        }
        sqlite3_bind_text(stmt, 1, model, -1, SQLITE_TRANSIENT)
        var rows: [Embedding] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            rows.append(try mapRow(stmt))
        }
        return rows
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> Embedding {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let itemId = text(1),
            let model = text(2),
            let vectorJSON = text(3),
            let textHash = text(4),
            let createdRaw = text(5)
        else {
            throw OrbError.storage("invalid embedding row")
        }
        return Embedding(
            id: id,
            itemId: itemId,
            model: model,
            vector: try decodeVector(vectorJSON),
            textHash: textHash,
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date()
        )
    }

    private func encodeVector(_ vector: [Double]) throws -> String {
        let data = try JSONEncoder().encode(vector)
        guard let json = String(data: data, encoding: .utf8) else {
            throw OrbError.invalidData("Failed to encode embedding vector")
        }
        return json
    }

    private func decodeVector(_ json: String) throws -> [Double] {
        guard let data = json.data(using: .utf8) else {
            throw OrbError.invalidData("Invalid embedding JSON")
        }
        return try JSONDecoder().decode([Double].self, from: data)
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
