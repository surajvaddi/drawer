import Foundation

struct FuzzySearchService: Sendable {
    let threshold: Double

    init(threshold: Double = 0.6) {
        self.threshold = threshold
    }

    func search(query: String, in items: [Item], limit: Int = 20) -> [Item] {
        let q = query.lowercased()
        guard !q.isEmpty else { return Array(items.prefix(limit)) }
        return items
            .compactMap { item -> (Item, Double)? in
                let candidates = [item.title, item.preview, item.contentText ?? ""]
                let best = candidates.map { similarity(q, $0.lowercased()) }.max() ?? 0
                return best >= threshold ? (item, best) : nil
            }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map(\.0)
    }

    func similarity(_ lhs: String, _ rhs: String) -> Double {
        if rhs.contains(lhs) || lhs.contains(rhs) { return 1 }
        if lhs.isEmpty || rhs.isEmpty { return 0 }
        let distance = levenshtein(lhs, rhs)
        let maxLen = max(lhs.count, rhs.count)
        return 1 - (Double(distance) / Double(maxLen))
    }

    private func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let a = Array(lhs)
        let b = Array(rhs)
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                dist[i][j] = min(dist[i - 1][j] + 1, dist[i][j - 1] + 1, dist[i - 1][j - 1] + cost)
            }
        }
        return dist[a.count][b.count]
    }
}
