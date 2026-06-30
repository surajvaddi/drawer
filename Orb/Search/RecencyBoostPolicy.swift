import Foundation

struct RecencyBoostPolicy: Sendable {
    let maxBoost: Double
    let halfLifeHours: Double

    init(maxBoost: Double = 25, halfLifeHours: Double = 24) {
        self.maxBoost = maxBoost
        self.halfLifeHours = halfLifeHours
    }

    func score(for item: Item, now: Date = Date()) -> Double {
        let reference = item.lastAccessedAt ?? item.createdAt
        let hours = now.timeIntervalSince(reference) / 3600
        return maxBoost * pow(0.5, hours / halfLifeHours)
    }

    func rank(_ items: [Item], now: Date = Date()) -> [Item] {
        items.sorted { score(for: $0, now: now) > score(for: $1, now: now) }
    }
}
