import Foundation
import SQLite3

struct ItemRepository: Sendable {
    let manager: DatabaseManager

    func create(_ item: Item) throws -> Item {
        var newItem = item
        if newItem.id.isEmpty { newItem.id = UUID().uuidString }
        let now = Date()
        newItem.createdAt = now
        newItem.updatedAt = now
        try insert(newItem)
        return newItem
    }

    func fetch(id: String) throws -> Item? {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM items WHERE id = ? LIMIT 1;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch item failed")
        }
        sqlite3_bind_text(stmt, 1, id, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return try mapRow(stmt)
    }

    func update(_ item: Item) throws -> Item {
        var updated = item
        updated.updatedAt = Date()
        try manager.exec(
            """
            UPDATE items SET
              type='\(escape(item.type.rawValue))',
              title='\(escape(updated.title))',
              preview='\(escape(updated.preview))',
              content_text=\(sqlOptional(updated.contentText)),
              content_html=\(sqlOptional(updated.contentHTML)),
              source_url=\(sqlOptional(updated.sourceURL)),
              source_app=\(sqlOptional(updated.sourceApp)),
              source_window_title=\(sqlOptional(updated.sourceWindowTitle)),
              original_created_at=\(sqlOptionalDate(updated.originalCreatedAt)),
              created_at='\(DBDateCodec.string(from: updated.createdAt))',
              updated_at='\(DBDateCodec.string(from: updated.updatedAt))',
              last_accessed_at=\(sqlOptionalDate(updated.lastAccessedAt)),
              drawer_id=\(sqlOptional(updated.drawerId)),
              is_pinned=\(updated.isPinned ? 1 : 0),
              is_favorite=\(updated.isFavorite ? 1 : 0),
              is_archived=\(updated.isArchived ? 1 : 0),
              sensitivity='\(escape(updated.sensitivity.rawValue))',
              user_note=\(sqlOptional(updated.userNote)),
              sort_order=\(updated.sortOrder),
              source_item_id=\(sqlOptional(updated.sourceItemId))
            WHERE id='\(escape(updated.id))';
            """
        )
        return updated
    }

    func delete(id: String) throws {
        try manager.exec("DELETE FROM items WHERE id='\(escape(id))';")
    }

    func listRecent(limit: Int = 50) throws -> [Item] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM items WHERE is_archived = 0 ORDER BY is_pinned DESC, sort_order ASC, created_at DESC LIMIT ?;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list recent failed")
        }
        sqlite3_bind_int(stmt, 1, Int32(limit))
        return try collect(stmt)
    }

    func listPinned() throws -> [Item] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM items WHERE is_pinned = 1 AND is_archived = 0 ORDER BY sort_order ASC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list pinned failed")
        }
        return try collect(stmt)
    }

    func listByDrawer(_ drawerID: String) throws -> [Item] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT * FROM items WHERE drawer_id = ? AND is_archived = 0 ORDER BY sort_order ASC, created_at DESC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list by drawer failed")
        }
        sqlite3_bind_text(stmt, 1, drawerID, -1, SQLITE_TRANSIENT)
        return try collect(stmt)
    }

    func updateSortOrder(itemIDsInOrder: [String]) throws {
        for (index, id) in itemIDsInOrder.enumerated() {
            try manager.exec(
                """
                UPDATE items SET sort_order=\(index), updated_at='\(DBDateCodec.string(from: Date()))'
                WHERE id='\(escape(id))';
                """
            )
        }
    }

    func moveToDrawer(itemID: String, drawerID: String?) throws {
        try manager.exec(
            """
            UPDATE items SET drawer_id=\(sqlOptional(drawerID)), updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE id='\(escape(itemID))';
            """
        )
    }

    func updateLastAccessed(id: String, at date: Date = Date()) throws {
        try manager.exec(
            """
            UPDATE items SET last_accessed_at='\(DBDateCodec.string(from: date))', updated_at='\(DBDateCodec.string(from: date))'
            WHERE id='\(escape(id))';
            """
        )
    }

    func bulkArchive(ids: [String]) throws {
        for id in ids {
            try archive(id: id)
        }
    }

    func bulkDelete(ids: [String]) throws {
        for id in ids {
            try delete(id: id)
        }
    }

    func listAll(includeArchived: Bool = false) throws -> [Item] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = includeArchived
            ? "SELECT * FROM items ORDER BY created_at DESC;"
            : "SELECT * FROM items WHERE is_archived = 0 ORDER BY created_at DESC;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list all items failed")
        }
        return try collect(stmt)
    }

    func archive(id: String) throws {
        try manager.exec(
            """
            UPDATE items SET is_archived = 1, updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE id='\(escape(id))';
            """
        )
    }

    private func insert(_ item: Item) throws {
        try manager.exec(
            """
            INSERT INTO items (
              id, type, title, preview, content_text, content_html, source_url, source_app,
              source_window_title, original_created_at, created_at, updated_at, last_accessed_at,
              drawer_id, is_pinned, is_favorite, is_archived, sensitivity, user_note, sort_order, source_item_id
            ) VALUES (
              '\(escape(item.id))',
              '\(escape(item.type.rawValue))',
              '\(escape(item.title))',
              '\(escape(item.preview))',
              \(sqlOptional(item.contentText)),
              \(sqlOptional(item.contentHTML)),
              \(sqlOptional(item.sourceURL)),
              \(sqlOptional(item.sourceApp)),
              \(sqlOptional(item.sourceWindowTitle)),
              \(sqlOptionalDate(item.originalCreatedAt)),
              '\(DBDateCodec.string(from: item.createdAt))',
              '\(DBDateCodec.string(from: item.updatedAt))',
              \(sqlOptionalDate(item.lastAccessedAt)),
              \(sqlOptional(item.drawerId)),
              \(item.isPinned ? 1 : 0),
              \(item.isFavorite ? 1 : 0),
              \(item.isArchived ? 1 : 0),
              '\(escape(item.sensitivity.rawValue))',
              \(sqlOptional(item.userNote)),
              \(item.sortOrder),
              \(sqlOptional(item.sourceItemId))
            );
            """
        )
    }

    private func collect(_ stmt: OpaquePointer?) throws -> [Item] {
        var items: [Item] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            items.append(try mapRow(stmt))
        }
        return items
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> Item {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let typeRaw = text(1),
            let type = ItemType(rawValue: typeRaw),
            let title = text(2),
            let preview = text(3),
            let createdRaw = text(10),
            let updatedRaw = text(11),
            let sensitivityRaw = text(17),
            let sensitivity = SensitivityLevel(rawValue: sensitivityRaw)
        else {
            throw OrbError.storage("invalid item row")
        }
        return Item(
            id: id,
            type: type,
            title: title,
            preview: preview,
            contentText: text(4),
            contentHTML: text(5),
            sourceURL: text(6),
            sourceApp: text(7),
            sourceWindowTitle: text(8),
            originalCreatedAt: text(9).flatMap(DBDateCodec.date(from:)),
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date(),
            updatedAt: DBDateCodec.date(from: updatedRaw) ?? Date(),
            lastAccessedAt: text(12).flatMap(DBDateCodec.date(from:)),
            drawerId: text(13),
            isPinned: sqlite3_column_int(stmt, 14) == 1,
            isFavorite: sqlite3_column_int(stmt, 15) == 1,
            isArchived: sqlite3_column_int(stmt, 16) == 1,
            sensitivity: sensitivity,
            userNote: sqlite3_column_count(stmt) > 18 ? text(18) : nil,
            sortOrder: sqlite3_column_count(stmt) > 19 ? Int(sqlite3_column_int(stmt, 19)) : 0,
            sourceItemId: sqlite3_column_count(stmt) > 20 ? text(20) : nil
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }

    private func sqlOptional(_ value: String?) -> String {
        guard let value else { return "NULL" }
        return "'\(escape(value))'"
    }

    private func sqlOptionalDate(_ value: Date?) -> String {
        guard let value else { return "NULL" }
        return "'\(DBDateCodec.string(from: value))'"
    }
}

enum DBDateCodec {
    private static let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
