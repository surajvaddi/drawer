import Foundation
import SQLite3

struct DrawerRepository: Sendable {
    let manager: DatabaseManager

    func create(_ drawer: Drawer) throws -> Drawer {
        var newDrawer = drawer
        if newDrawer.id.isEmpty { newDrawer.id = UUID().uuidString }
        let now = Date()
        newDrawer.createdAt = now
        newDrawer.updatedAt = now
        try insert(newDrawer)
        return newDrawer
    }

    func fetchAll() throws -> [Drawer] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM drawers ORDER BY sort_order ASC, name ASC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch drawers failed")
        }
        return try collect(stmt)
    }

    func fetchTree() throws -> [Drawer] {
        try fetchAll()
    }

    func reorder(drawerIDsInOrder: [String]) throws {
        for (index, id) in drawerIDsInOrder.enumerated() {
            try manager.exec(
                """
                UPDATE drawers SET sort_order=\(index), updated_at='\(DBDateCodec.string(from: Date()))'
                WHERE id='\(escape(id))';
                """
            )
        }
    }

    func setPinned(id: String, pinned: Bool) throws {
        try manager.exec(
            """
            UPDATE drawers SET is_pinned=\(pinned ? 1 : 0), updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE id='\(escape(id))';
            """
        )
    }

    private func insert(_ drawer: Drawer) throws {
        try manager.exec(
            """
            INSERT INTO drawers (
              id, name, icon, color, parent_drawer_id, description, sort_order, is_pinned, created_at, updated_at
            ) VALUES (
              '\(escape(drawer.id))',
              '\(escape(drawer.name))',
              \(sqlOptional(drawer.icon)),
              \(sqlOptional(drawer.color)),
              \(sqlOptional(drawer.parentDrawerId)),
              \(sqlOptional(drawer.description)),
              \(drawer.sortOrder),
              \(drawer.isPinned ? 1 : 0),
              '\(DBDateCodec.string(from: drawer.createdAt))',
              '\(DBDateCodec.string(from: drawer.updatedAt))'
            );
            """
        )
    }

    private func collect(_ stmt: OpaquePointer?) throws -> [Drawer] {
        var drawers: [Drawer] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            drawers.append(try mapRow(stmt))
        }
        return drawers
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> Drawer {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard let id = text(0), let name = text(1), let createdRaw = text(8), let updatedRaw = text(9) else {
            throw OrbError.storage("invalid drawer row")
        }
        return Drawer(
            id: id,
            name: name,
            icon: text(2),
            color: text(3),
            parentDrawerId: text(4),
            description: text(5),
            sortOrder: Int(sqlite3_column_int(stmt, 6)),
            isPinned: sqlite3_column_int(stmt, 7) == 1,
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date(),
            updatedAt: DBDateCodec.date(from: updatedRaw) ?? Date()
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
