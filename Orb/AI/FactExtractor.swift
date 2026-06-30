import Foundation

struct FactExtractor: Sendable {
    let provider: AIProvider
    let annotations: AIAnnotationRepository
    let factCards: FactCardRepository
    let queue: AIJobQueue

    func extract(from item: Item, drawerID: String? = nil) async throws -> [FactCard] {
        let text = item.contentText ?? item.preview
        let facts = try await provider.extractFacts(from: text)
        var cards: [FactCard] = []
        for fact in facts {
            let card = try factCards.create(text: fact, sourceItem: item, drawerID: drawerID ?? item.drawerId)
            cards.append(card)
        }
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .facts, model: provider.modelName, content: ["facts": facts.joined(separator: "\n")])
        )
        return cards
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .facts)
    }
}
