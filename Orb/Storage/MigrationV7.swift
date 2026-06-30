import Foundation
import SQLite3

struct MigrationV7: DatabaseMigration {
    let version = 7
    let name = "private_drawers_and_app_settings"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        ALTER TABLE drawers ADD COLUMN is_private INTEGER NOT NULL DEFAULT 0;
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        );
        CREATE INDEX idx_drawers_is_private ON drawers(is_private);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v7 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
