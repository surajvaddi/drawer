import Foundation

struct ItemPinController: Sendable {
    let repository: ItemRepository

    func togglePin(item: Item) throws -> Item {
        var updated = item
        updated.isPinned.toggle()
        return try repository.update(updated)
    }

    func toggleFavorite(item: Item) throws -> Item {
        var updated = item
        updated.isFavorite.toggle()
        return try repository.update(updated)
    }

    func sortPinnedFirst(_ items: [Item]) -> [Item] {
        items.sorted {
            if $0.isPinned != $1.isPinned { return $0.isPinned && !$1.isPinned }
            return $0.sortOrder < $1.sortOrder
        }
    }
}
