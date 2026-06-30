import Foundation

struct SearchHit: Equatable, Sendable {
    var itemID: String
    var score: Double
}

struct SearchRanker: Sendable {
    func rank(items: [Item], query: String, now: Date = Date()) -> [SearchHit] {
        let q = query.lowercased()
        guard !q.isEmpty else {
            return items.map { SearchHit(itemID: $0.id, score: 0) }
        }
        return items.map { item in
            var score = 0.0
            if item.title.lowercased().contains(q) { score += 10 }
            if item.preview.lowercased().contains(q) { score += 5 }
            if item.contentText?.lowercased().contains(q) == true { score += 3 }
            if item.userNote?.lowercased().contains(q) == true { score += 2 }
            if item.isPinned { score += 20 }
            let reference = item.lastAccessedAt ?? item.createdAt
            let ageHours = now.timeIntervalSince(reference) / 3600
            score += max(0, 10 - ageHours / 24)
            return SearchHit(itemID: item.id, score: score)
        }
        .sorted { $0.score > $1.score }
    }
}
