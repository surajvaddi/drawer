import Foundation
import SQLite3

struct CaptureEventRepository: Sendable {
    let manager: DatabaseManager

    func log(_ event: CaptureEvent) throws -> CaptureEvent {
        let typesJSON = (try? JSONEncoder().encode(event.pasteboardTypes)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        let metadataJSON = (try? JSONEncoder().encode(event.rawMetadata)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        try manager.exec(
            """
            INSERT INTO capture_events (
              id, item_id, method, source_app, pasteboard_types, raw_metadata, created_at
            ) VALUES (
              '\(escape(event.id))',
              '\(escape(event.itemId))',
              '\(escape(event.method.rawValue))',
              \(sqlOptional(event.sourceApp)),
              '\(escape(typesJSON))',
              '\(escape(metadataJSON))',
              '\(DBDateCodec.string(from: event.createdAt))'
            );
            """
        )
        return event
    }

    func fetchPending() throws -> [CaptureEvent] {
        try fetchAll()
    }

    func fetchAll() throws -> [CaptureEvent] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM capture_events ORDER BY created_at ASC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare capture events failed")
        }
        var events: [CaptureEvent] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            events.append(try mapRow(stmt))
        }
        return events
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> CaptureEvent {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let itemId = text(1),
            let methodRaw = text(2),
            let method = CaptureMethod(rawValue: methodRaw),
            let createdRaw = text(6)
        else { throw OrbError.storage("invalid capture event row") }
        let typesJSON = text(4) ?? "[]"
        let metadataJSON = text(5) ?? "{}"
        let types = (try? JSONDecoder().decode([String].self, from: Data(typesJSON.utf8))) ?? []
        let metadata = (try? JSONDecoder().decode([String: String].self, from: Data(metadataJSON.utf8))) ?? [:]
        return CaptureEvent(
            id: id,
            itemId: itemId,
            method: method,
            sourceApp: text(3),
            pasteboardTypes: types,
            rawMetadata: metadata,
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date()
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }

    private func sqlOptional(_ value: String?) -> String {
        guard let value else { return "NULL" }
        return "'\(escape(value))'"
    }
}
