import Foundation

struct DrawerSearchController: Sendable {
    let search: SearchRepository
    let fuzzy: FuzzySearchService
    let debounceNanoseconds: UInt64

    init(search: SearchRepository, fuzzy: FuzzySearchService = FuzzySearchService(), debounceMilliseconds: Int = 200) {
        self.search = search
        self.fuzzy = fuzzy
        self.debounceNanoseconds = UInt64(debounceMilliseconds) * 1_000_000
    }

    func results(for query: String, recents: [Item]) throws -> [Item] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return recents }
        let primary = try search.search(trimmed)
        if primary.count >= 3 { return primary }
        let fallback = fuzzy.search(query: trimmed, in: recents)
        return primary + fallback.filter { candidate in !primary.contains(where: { $0.id == candidate.id }) }
    }

    func debounceInterval() -> UInt64 {
        debounceNanoseconds
    }
}
