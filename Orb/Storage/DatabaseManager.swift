import Foundation
import SQLite3

protocol DatabaseMigration: Sendable {
    var version: Int { get }
    var name: String { get }
    func apply(on db: OpaquePointer) throws
}

struct DatabaseManager: @unchecked Sendable {
    private(set) var db: OpaquePointer?
    let paths: StoragePaths

    init(paths: StoragePaths) {
        self.paths = paths
    }

    func open() throws {
        try paths.ensureDirectoriesExist()
        var handle: OpaquePointer?
        let code = sqlite3_open(paths.databaseURL.path, &handle)
        guard code == SQLITE_OK, let handle else {
            throw OrbError.storage("Failed to open database: \(String(cString: sqlite3_errmsg(handle)))")
        }
        db = handle
        try exec("PRAGMA foreign_keys = ON;")
    }

    func close() {
        if let db {
            sqlite3_close(db)
        }
        self.db = nil
    }

    func migrationVersion() throws -> Int {
        try ensureMigrationsTable()
        guard let db else { throw OrbError.storage("Database not open") }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT COALESCE(MAX(version), 0) FROM schema_migrations;"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("Failed to read migration version")
        }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }

    func migrate(using migrations: [any DatabaseMigration]) throws {
        guard db != nil else { throw OrbError.storage("Database not open") }
        try ensureMigrationsTable()
        let current = try migrationVersion()
        let pending = migrations.filter { $0.version > current }.sorted { $0.version < $1.version }
        for migration in pending {
            try exec("BEGIN IMMEDIATE TRANSACTION;")
            do {
                try migration.apply(on: db!)
                try exec("INSERT INTO schema_migrations(version, name) VALUES (\(migration.version), '\(escape(migration.name))');")
                try exec("COMMIT;")
            } catch {
                try? exec("ROLLBACK;")
                throw error
            }
        }
    }

    @discardableResult
    func exec(_ sql: String) throws -> Int {
        guard let db else { throw OrbError.storage("Database not open") }
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Unknown SQLite error"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
        return Int(sqlite3_changes(db))
    }

    private func ensureMigrationsTable() throws {
        try exec(
            """
            CREATE TABLE IF NOT EXISTS schema_migrations (
              version INTEGER PRIMARY KEY,
              name TEXT NOT NULL,
              applied_at TEXT NOT NULL DEFAULT (datetime('now'))
            );
            """
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}
