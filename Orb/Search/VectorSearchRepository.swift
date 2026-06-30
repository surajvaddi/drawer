import Foundation

struct VectorSearchHit: Equatable, Sendable {
    var itemId: String
    var score: Double
}

struct VectorSearchRepository: Sendable {
    let embeddings: StoredEmbeddingRepository
    let provider: EmbeddingProvider

    func search(query: String, limit: Int = 20) async throws -> [VectorSearchHit] {
        let queryVector = try await provider.embed(text: query)
        let stored = try embeddings.listAll(model: provider.modelName)
        return stored
            .map { VectorSearchHit(itemId: $0.itemId, score: cosineSimilarity(queryVector, $0.vector)) }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }

    private func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        let dot = zip(a, b).map(*).reduce(0, +)
        let magA = sqrt(a.map { $0 * $0 }.reduce(0, +))
        let magB = sqrt(b.map { $0 * $0 }.reduce(0, +))
        guard magA > 0, magB > 0 else { return 0 }
        return dot / (magA * magB)
    }
}
