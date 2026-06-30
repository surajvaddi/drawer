import Foundation

struct TitleGenerator: Sendable {
    let provider: AIProvider
    let annotations: AIAnnotationRepository
    let queue: AIJobQueue

    func generate(for item: Item) async throws -> String {
        let text = item.contentText ?? item.preview
        let title = try await provider.generateTitle(from: text)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .title, model: provider.modelName, content: ["value": title])
        )
        return title
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .title)
    }
}
