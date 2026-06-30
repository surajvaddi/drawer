import Foundation
import SQLite3

struct AppSettingsRepository: Sendable {
    let manager: DatabaseManager

    func get(_ key: String, default defaultValue: String) throws -> String {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT value FROM app_settings WHERE key = ? LIMIT 1;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare settings get failed")
        }
        sqlite3_bind_text(stmt, 1, key, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW, let c = sqlite3_column_text(stmt, 0) else {
            return defaultValue
        }
        return String(cString: c)
    }

    func set(_ key: String, value: String) throws {
        try manager.exec(
            """
            INSERT INTO app_settings(key, value) VALUES ('\(escape(key))', '\(escape(value))')
            ON CONFLICT(key) DO UPDATE SET value=excluded.value;
            """
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
