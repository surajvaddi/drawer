import Foundation
import SQLite3

struct MigrationV5: DatabaseMigration {
    let version = 5
    let name = "item_notes_and_sort_order"

    func apply(on db: OpaquePointer) throws {
        let sql = """
        ALTER TABLE items ADD COLUMN user_note TEXT;
        ALTER TABLE items ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0;
        CREATE INDEX idx_items_sort_order ON items(sort_order);
        """
        try execSQL(sql, on: db)
    }

    private func execSQL(_ sql: String, on db: OpaquePointer) throws {
        var errorMessage: UnsafeMutablePointer<CChar>?
        let code = sqlite3_exec(db, sql, nil, nil, &errorMessage)
        if code != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? "Migration v5 failed"
            sqlite3_free(errorMessage)
            throw OrbError.storage(message)
        }
    }
}
