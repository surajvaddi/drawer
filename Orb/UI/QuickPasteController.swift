import AppKit
import Foundation

struct QuickPasteController: Sendable {
    let items: ItemRepository
    let pasteboard: PasteboardProviding
    let writer: PasteboardWriter
    let recency: RecencyBoostPolicy

    init(
        items: ItemRepository,
        pasteboard: PasteboardProviding = NSPasteboard.general,
        writer: PasteboardWriter? = nil,
        recency: RecencyBoostPolicy = RecencyBoostPolicy()
    ) {
        self.items = items
        self.pasteboard = pasteboard
        self.writer = writer ?? PasteboardWriter(pasteboard: pasteboard)
        self.recency = recency
    }

    func copy(item: Item, updateAccessTime: Bool = true) throws {
        try writer.write(item: item)
        if updateAccessTime {
            try items.updateLastAccessed(id: item.id)
        }
    }

    func rankedRecents(from items: [Item]) -> [Item] {
        recency.rank(items)
    }
}
