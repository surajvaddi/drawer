import Foundation

struct DrawerKeyboardNavigator: Sendable {
    private(set) var selectedIndex: Int = 0
    var previewOpen: Bool = false

    mutating func moveDown(itemCount: Int) {
        guard itemCount > 0 else { selectedIndex = 0; return }
        selectedIndex = min(selectedIndex + 1, itemCount - 1)
    }

    mutating func moveUp() {
        selectedIndex = max(selectedIndex - 1, 0)
    }

    mutating func openPreview() {
        previewOpen = true
    }

    func selectedItem(in items: [Item]) -> Item? {
        guard items.indices.contains(selectedIndex) else { return nil }
        return items[selectedIndex]
    }

    func archiveTarget(in items: [Item]) -> Item? {
        selectedItem(in: items)
    }
}
