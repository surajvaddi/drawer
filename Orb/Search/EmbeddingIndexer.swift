import Foundation
import CryptoKit

struct EmbeddingIndexer: Sendable {
    let provider: EmbeddingProvider
    let embeddings: StoredEmbeddingRepository
    let items: ItemRepository
    let chunker: DocumentChunker

    func index(item: Item) async throws -> Embedding {
        let text = [item.title, item.contentText ?? item.preview]
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = textHash(text)
        if let existing = try embeddings.fetch(itemId: item.id, model: provider.modelName),
           existing.textHash == hash {
            return existing
        }
        let vector = try await provider.embed(text: text)
        let embedding = Embedding(itemId: item.id, model: provider.modelName, vector: vector, textHash: hash)
        try embeddings.save(embedding)
        _ = try chunker.chunk(itemId: item.id, text: text)
        return embedding
    }

    func indexAll(limit: Int = 50) async throws -> Int {
        let recent = try items.listRecent(limit: limit)
        var count = 0
        for item in recent {
            _ = try await index(item: item)
            count += 1
        }
        return count
    }

    private func textHash(_ text: String) -> String {
        let digest = SHA256.hash(data: Data(text.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
