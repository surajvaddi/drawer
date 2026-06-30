import Foundation
import SQLite3

struct TagRepository: Sendable {
    let manager: DatabaseManager

    func create(name: String, color: String? = nil) throws -> Tag {
        let normalized = Tag.normalize(name)
        if let existing = try fetchByName(normalized) {
            return existing
        }
        let tag = Tag(name: normalized, color: color)
        try manager.exec(
            """
            INSERT INTO tags(id, name, color) VALUES (
              '\(escape(tag.id))', '\(escape(tag.name))', \(sqlOptional(tag.color))
            );
            """
        )
        return tag
    }

    func link(itemId: String, tagId: String) throws {
        try manager.exec(
            """
            INSERT OR IGNORE INTO item_tags(item_id, tag_id) VALUES ('\(escape(itemId))', '\(escape(tagId))');
            """
        )
    }

    func unlink(itemId: String, tagId: String) throws {
        try manager.exec(
            """
            DELETE FROM item_tags WHERE item_id='\(escape(itemId))' AND tag_id='\(escape(tagId))';
            """
        )
    }

    func fetchAll() throws -> [Tag] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT id, name, color FROM tags ORDER BY name ASC;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch all tags failed")
        }
        var tags: [Tag] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let id = sqlite3_column_text(stmt, 0), let name = sqlite3_column_text(stmt, 1) else { continue }
            let color = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
            tags.append(Tag(id: String(cString: id), name: String(cString: name), color: color))
        }
        return tags
    }

    func searchPrefix(_ query: String) throws -> [Tag] {
        let normalized = Tag.normalize(query)
        guard !normalized.isEmpty else { return try fetchAll() }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT id, name, color FROM tags WHERE name LIKE ? ORDER BY name ASC;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare tag prefix search failed")
        }
        sqlite3_bind_text(stmt, 1, "\(normalized)%", -1, SQLITE_TRANSIENT)
        var tags: [Tag] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let id = sqlite3_column_text(stmt, 0), let name = sqlite3_column_text(stmt, 1) else { continue }
            let color = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
            tags.append(Tag(id: String(cString: id), name: String(cString: name), color: color))
        }
        return tags
    }

    func itemIDs(withTagID tagID: String) throws -> [String] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT item_id FROM item_tags WHERE tag_id = ?;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare item ids for tag failed")
        }
        sqlite3_bind_text(stmt, 1, tagID, -1, SQLITE_TRANSIENT)
        var ids: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let c = sqlite3_column_text(stmt, 0) { ids.append(String(cString: c)) }
        }
        return ids
    }

    func tags(for itemId: String) throws -> [Tag] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = """
        SELECT t.id, t.name, t.color FROM tags t
        INNER JOIN item_tags it ON it.tag_id = t.id
        WHERE it.item_id = ? ORDER BY t.name ASC;
        """
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare tags for item failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        var tags: [Tag] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            guard let id = sqlite3_column_text(stmt, 0), let name = sqlite3_column_text(stmt, 1) else { continue }
            let color = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
            tags.append(Tag(id: String(cString: id), name: String(cString: name), color: color))
        }
        return tags
    }

    private func fetchByName(_ name: String) throws -> Tag? {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT id, name, color FROM tags WHERE name = ? LIMIT 1;", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fetch tag failed")
        }
        sqlite3_bind_text(stmt, 1, name, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW,
              let id = sqlite3_column_text(stmt, 0),
              let tagName = sqlite3_column_text(stmt, 1) else { return nil }
        let color = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
        return Tag(id: String(cString: id), name: String(cString: tagName), color: color)
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }

    private func sqlOptional(_ value: String?) -> String {
        guard let value else { return "NULL" }
        return "'\(escape(value))'"
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
