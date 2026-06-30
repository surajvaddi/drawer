import Foundation

struct TagFilterController: Sendable {
    var selectedTagID: String?

    func filter(items: [Item], tagItemIDs: Set<String>) -> [Item] {
        guard let selectedTagID else { return items }
        return items.filter { tagItemIDs.contains($0.id) }
    }

    func clear() -> String? {
        nil
    }
}
