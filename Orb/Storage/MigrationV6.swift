import Foundation
import SQLite3

struct MigrationV6: DatabaseMigration {
    let version = 6
    let name = "source_item_id_for_facts"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        ALTER TABLE items ADD COLUMN source_item_id TEXT;
        CREATE INDEX idx_items_source_item_id ON items(source_item_id);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v6 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
