import Foundation

struct SemanticQuickPasteRanker: Sendable {
    let vectorSearch: VectorSearchRepository

    func rank(query: String, candidates: [Item], limit: Int = 10) async throws -> [Item] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Array(candidates.prefix(limit))
        }
        let hits = try await vectorSearch.search(query: query, limit: limit * 2)
        let scoreByID = Dictionary(uniqueKeysWithValues: hits.map { ($0.itemId, $0.score) })
        let candidateIDs = Set(candidates.map(\.id))
        return candidates
            .sorted { (scoreByID[$0.id] ?? 0) > (scoreByID[$1.id] ?? 0) }
            .filter { candidateIDs.contains($0.id) }
            .prefix(limit)
            .map { $0 }
    }
}
