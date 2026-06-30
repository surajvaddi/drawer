import Foundation

struct HybridSearchHit: Equatable, Sendable {
    var itemId: String
    var ftsScore: Double
    var vectorScore: Double

    var combinedScore: Double {
        ftsScore * 0.6 + vectorScore * 0.4
    }
}

struct HybridSearchMerger: Sendable {
    let search: SearchRepository
    let vectorSearch: VectorSearchRepository

    func search(_ query: String, limit: Int = 30) async throws -> [HybridSearchHit] {
        let ftsItems = try search.search(query, limit: limit)
        let vectorHits = try await vectorSearch.search(query: query, limit: limit)
        let vectorByID = Dictionary(uniqueKeysWithValues: vectorHits.map { ($0.itemId, $0.score) })
        var merged: [HybridSearchHit] = []
        for (index, item) in ftsItems.enumerated() {
            let ftsScore = Double(ftsItems.count - index)
            let vectorScore = vectorByID[item.id] ?? 0
            merged.append(HybridSearchHit(itemId: item.id, ftsScore: ftsScore, vectorScore: vectorScore))
        }
        for hit in vectorHits where !merged.contains(where: { $0.itemId == hit.itemId }) {
            merged.append(HybridSearchHit(itemId: hit.itemId, ftsScore: 0, vectorScore: hit.score))
        }
        return merged.sorted { $0.combinedScore > $1.combinedScore }.prefix(limit).map { $0 }
    }
}
