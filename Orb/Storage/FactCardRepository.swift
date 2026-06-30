import Foundation

struct FactCardRepository: Sendable {
    let items: ItemRepository

    func create(text: String, sourceItem: Item?, drawerID: String? = DefaultDataSeeder.inboxDrawerID) throws -> FactCard {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw OrbError.invalidData("Fact text cannot be empty") }
        let item = try items.create(
            Item(
                type: .fact,
                title: String(trimmed.prefix(80)),
                preview: trimmed,
                contentText: trimmed,
                drawerId: drawerID,
                sourceItemId: sourceItem?.id
            )
        )
        return FactCard(text: trimmed, sourceItemId: sourceItem?.id, itemId: item.id)
    }

    func fetch(itemID: String) throws -> FactCard? {
        guard let item = try items.fetch(id: itemID), item.type == .fact else { return nil }
        return FactCard(text: item.contentText ?? item.title, sourceItemId: item.sourceItemId, itemId: item.id)
    }

    func update(_ fact: FactCard) throws -> FactCard {
        guard var item = try items.fetch(id: fact.itemId) else {
            throw OrbError.invalidData("Fact item not found")
        }
        item.title = String(fact.text.prefix(80))
        item.preview = fact.text
        item.contentText = fact.text
        item.sourceItemId = fact.sourceItemId
        _ = try items.update(item)
        return fact
    }

    func delete(itemID: String) throws {
        try items.delete(id: itemID)
    }

    func copyFormat(_ fact: FactCard, sourceTitle: String?) -> String {
        if let sourceTitle {
            return "\(fact.text) — \(sourceTitle)"
        }
        return fact.text
    }
}
