import Foundation
import SQLite3

struct SearchRepository: Sendable {
    let manager: DatabaseManager
    let items: ItemRepository
    let queryBuilder: FTSQueryBuilder
    let filterParser: SearchFilterParser
    let ranker: SearchRanker

    init(
        manager: DatabaseManager,
        items: ItemRepository? = nil,
        queryBuilder: FTSQueryBuilder = FTSQueryBuilder(),
        filterParser: SearchFilterParser = SearchFilterParser(),
        ranker: SearchRanker = SearchRanker()
    ) {
        self.manager = manager
        self.items = items ?? ItemRepository(manager: manager)
        self.queryBuilder = queryBuilder
        self.filterParser = filterParser
        self.ranker = ranker
    }

    func search(_ rawQuery: String, limit: Int = 50) throws -> [Item] {
        let filters = filterParser.parse(rawQuery)
        let ftsQuery = queryBuilder.build(from: filters.text)
        var ids: [String]
        if ftsQuery.isEmpty {
            ids = try items.listRecent(limit: limit).map(\.id)
        } else {
            ids = try ftsSearch(ftsQuery, limit: limit)
        }
        var results = ids.compactMap { try? items.fetch(id: $0) }.compactMap { $0 }
        results = apply(filters, to: results)
        let ranked = ranker.rank(items: results, query: filters.text)
        let order = ranked.map(\.itemID)
        return results.sorted { lhs, rhs in
            (order.firstIndex(of: lhs.id) ?? Int.max) < (order.firstIndex(of: rhs.id) ?? Int.max)
        }
    }

    private func ftsSearch(_ query: String, limit: Int) throws -> [String] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT item_id FROM items_fts WHERE items_fts MATCH ? LIMIT ?;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare search failed")
        }
        sqlite3_bind_text(stmt, 1, query, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 2, Int32(limit))
        var ids: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let c = sqlite3_column_text(stmt, 0) { ids.append(String(cString: c)) }
        }
        return ids
    }

    private func apply(_ filters: ParsedSearchFilters, to items: [Item]) -> [Item] {
        items.filter { item in
            if !filters.types.isEmpty && !filters.types.contains(item.type) { return false }
            if !filters.drawerIDs.isEmpty, let drawerID = item.drawerId, !filters.drawerIDs.contains(drawerID) { return false }
            if !filters.sourceApps.isEmpty, let app = item.sourceApp?.lowercased(), !filters.sourceApps.contains(app) { return false }
            if let after = filters.after, item.createdAt < after { return false }
            if let before = filters.before, item.createdAt > before { return false }
            return true
        }
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
