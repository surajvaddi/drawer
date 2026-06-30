import Foundation
import SQLite3

struct AIAnnotationRepository: Sendable {
    let manager: DatabaseManager

    func upsert(_ annotation: AIAnnotation) throws -> AIAnnotation {
        let contentJSON = try encodeContent(annotation.content)
        let now = DBDateCodec.string(from: annotation.createdAt)
        try manager.exec(
            """
            INSERT INTO ai_annotations(id, item_id, kind, model, content_json, created_at)
            VALUES (
              '\(escape(annotation.id))',
              '\(escape(annotation.itemId))',
              '\(escape(annotation.kind.rawValue))',
              '\(escape(annotation.model))',
              '\(escape(contentJSON))',
              '\(now)'
            )
            ON CONFLICT(id) DO UPDATE SET
              model='\(escape(annotation.model))',
              content_json='\(escape(contentJSON))';
            """
        )
        return annotation
    }

    func fetch(itemId: String, kind: AIAnnotationKind) throws -> AIAnnotation? {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = """
        SELECT id, item_id, kind, model, content_json, created_at
        FROM ai_annotations WHERE item_id = ? AND kind = ? LIMIT 1;
        """
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch ai annotation failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, kind.rawValue, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return try mapRow(stmt)
    }

    func fetchAll(itemId: String) throws -> [AIAnnotation] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = """
        SELECT id, item_id, kind, model, content_json, created_at
        FROM ai_annotations WHERE item_id = ? ORDER BY created_at DESC;
        """
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list ai annotations failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        var rows: [AIAnnotation] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            rows.append(try mapRow(stmt))
        }
        return rows
    }

    func delete(itemId: String) throws {
        try manager.exec("DELETE FROM ai_annotations WHERE item_id='\(escape(itemId))';")
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> AIAnnotation {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let itemId = text(1),
            let kindRaw = text(2),
            let kind = AIAnnotationKind(rawValue: kindRaw),
            let model = text(3),
            let contentJSON = text(4),
            let createdRaw = text(5)
        else {
            throw OrbError.storage("invalid ai annotation row")
        }
        return AIAnnotation(
            id: id,
            itemId: itemId,
            kind: kind,
            model: model,
            content: try decodeContent(contentJSON),
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date()
        )
    }

    private func encodeContent(_ content: [String: String]) throws -> String {
        let data = try JSONEncoder().encode(content)
        guard let json = String(data: data, encoding: .utf8) else {
            throw OrbError.invalidData("Failed to encode AI annotation content")
        }
        return json
    }

    private func decodeContent(_ json: String) throws -> [String: String] {
        guard let data = json.data(using: .utf8) else {
            throw OrbError.invalidData("Invalid AI annotation JSON")
        }
        return try JSONDecoder().decode([String: String].self, from: data)
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
