import Foundation

struct RelatedItem: Equatable, Sendable {
    var itemId: String
    var score: Double
}

struct RelatedItemsEngine: Sendable {
    let items: ItemRepository
    let provider: AIProvider
    let queue: AIJobQueue

    func related(to item: Item, limit: Int = 8) async throws -> [RelatedItem] {
        let sourceText = [item.title, item.contentText ?? item.preview]
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sourceText.isEmpty else { return [] }
        let sourceVector = try await provider.embed(text: sourceText)
        let pool = try items.listRecent(limit: 100)
        var related: [RelatedItem] = []
        for candidate in pool where candidate.id != item.id {
            let text = [candidate.title, candidate.contentText ?? candidate.preview]
                .joined(separator: "\n")
            let vector = try await provider.embed(text: text)
            let score = cosineSimilarity(sourceVector, vector)
            if score > 0.5 {
                related.append(RelatedItem(itemId: candidate.id, score: score))
            }
        }
        return related.sorted { $0.score > $1.score }.prefix(limit).map { $0 }
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .related)
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
