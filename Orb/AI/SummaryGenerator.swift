import Foundation

struct SummaryGenerator: Sendable {
    let provider: AIProvider
    let annotations: AIAnnotationRepository
    let queue: AIJobQueue

    func generate(for item: Item) async throws -> String {
        let text = item.contentText ?? item.preview
        let summary = try await provider.generateSummary(from: text)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .summary, model: provider.modelName, content: ["value": summary])
        )
        return summary
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .summary)
    }
}
