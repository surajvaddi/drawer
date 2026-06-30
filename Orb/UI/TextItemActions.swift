import AppKit
import Foundation

struct TextItemActions: Sendable {
    let pasteboard: PasteboardProviding
    let repository: ItemRepository

    init(pasteboard: PasteboardProviding = NSPasteboard.general, repository: ItemRepository) {
        self.pasteboard = pasteboard
        self.repository = repository
    }

    func copyPlainText(_ item: Item) {
        pasteboard.clearContents()
        pasteboard.setString(item.contentText ?? item.preview, forType: .string)
    }

    func editContent(_ item: Item, newText: String) throws -> Item {
        var updated = item
        let normalizer = TextNormalizer()
        let normalized = normalizer.normalize(newText)
        updated.contentText = normalized
        updated.preview = normalizer.preview(from: normalized)
        if updated.title.isEmpty || updated.title == normalizer.title(from: item.contentText ?? "") {
            updated.title = normalizer.title(from: normalized)
        }
        return try repository.update(updated)
    }
}
