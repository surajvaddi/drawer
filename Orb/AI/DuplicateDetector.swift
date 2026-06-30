import CryptoKit
import Foundation

struct DuplicateCandidate: Equatable, Sendable {
    var itemId: String
    var score: Double
    var reason: String
}

struct DuplicateDetector: Sendable {
    let items: ItemRepository
    let provider: AIProvider
    let queue: AIJobQueue
    let threshold: Double

    init(items: ItemRepository, provider: AIProvider, queue: AIJobQueue, threshold: Double = 0.92) {
        self.items = items
        self.provider = provider
        self.queue = queue
        self.threshold = threshold
    }

    func findDuplicates(for item: Item, limit: Int = 10) async throws -> [DuplicateCandidate] {
        var candidates: [DuplicateCandidate] = []
        let all = try items.listRecent(limit: 200)

        if let url = item.sourceURL?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !url.isEmpty {
            for candidate in all where candidate.id != item.id {
                let other = candidate.sourceURL?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if other == url {
                    candidates.append(DuplicateCandidate(itemId: candidate.id, score: 1.0, reason: "url"))
                }
            }
        }

        if item.type == .text || item.type == .url {
            if let hash = contentHash(for: item) {
                for candidate in all where candidate.id != item.id {
                    if contentHash(for: candidate) == hash {
                        candidates.append(DuplicateCandidate(itemId: candidate.id, score: 1.0, reason: "text_hash"))
                    }
                }
            }
        }

        if item.type == .file, let checksum = fileChecksum(for: item) {
            for candidate in all where candidate.id != item.id && candidate.type == .file {
                if fileChecksum(for: candidate) == checksum {
                    candidates.append(DuplicateCandidate(itemId: candidate.id, score: 1.0, reason: "file_checksum"))
                }
            }
        }

        let sourceText = normalizedText(for: item) ?? ""
        if !sourceText.isEmpty {
            let sourceVector = try await provider.embed(text: sourceText)
            for candidate in all where candidate.id != item.id {
                guard let text = normalizedText(for: candidate), !text.isEmpty else { continue }
                let vector = try await provider.embed(text: text)
                let score = cosineSimilarity(sourceVector, vector)
                if score >= threshold {
                    candidates.append(DuplicateCandidate(itemId: candidate.id, score: score, reason: "semantic"))
                }
            }
        }

        var seen: Set<String> = []
        return candidates
            .sorted { $0.score > $1.score }
            .filter { seen.insert($0.itemId).inserted }
            .prefix(limit)
            .map { $0 }
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .duplicate)
    }

    private func normalizedText(for item: Item) -> String? {
        let joined = [item.title, item.contentText ?? item.preview]
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return joined.isEmpty ? nil : joined
    }

    private func contentHash(for item: Item) -> String? {
        let text = (item.contentText ?? item.preview)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !text.isEmpty else { return nil }
        return textHash(text)
    }

    private func fileChecksum(for item: Item) -> String? {
        contentHash(for: item)
    }

    private func textHash(_ text: String) -> String {
        let digest = SHA256.hash(data: Data(text.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
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
