import Foundation

struct AIWorker: Sendable {
    let queue: AIJobQueue
    let items: ItemRepository
    let annotations: AIAnnotationRepository
    let provider: AIProvider
    let privacyGate: AIPrivacyGate

    func processNext() async throws -> Bool {
        guard let job = try queue.dequeue() else { return false }
        let usesCloud = !(provider is MockAIProvider)
        let decision = privacyGate.evaluate(operation: job.kind.rawValue, usesCloud: usesCloud)
        switch decision {
        case .blocked(let reason):
            try queue.markFailed(id: job.id, error: reason)
            return true
        case .requiresConfirmation:
            try queue.markFailed(id: job.id, error: "Awaiting user confirmation for cloud AI")
            return true
        case .allowed:
            break
        }

        do {
            guard let item = try items.fetch(id: job.itemId) else {
                throw OrbError.notFound("Item not found for AI job")
            }
            let text = [item.title, item.contentText ?? item.preview]
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            try await handle(job: job, text: text)
            try queue.markCompleted(id: job.id)
        } catch {
            try queue.markFailed(id: job.id, error: error.localizedDescription)
        }
        return true
    }

    func drain(maxJobs: Int = 10) async throws -> Int {
        var processed = 0
        while processed < maxJobs {
            let didWork = try await processNext()
            guard didWork else { break }
            processed += 1
        }
        return processed
    }

    private func handle(job: AIJob, text: String) async throws {
        switch job.kind {
        case .title:
            let title = try await provider.generateTitle(from: text)
            _ = try annotations.upsert(
                AIAnnotation(itemId: job.itemId, kind: .title, model: provider.modelName, content: ["value": title])
            )
        case .summary:
            let summary = try await provider.generateSummary(from: text)
            _ = try annotations.upsert(
                AIAnnotation(itemId: job.itemId, kind: .summary, model: provider.modelName, content: ["value": summary])
            )
        case .tags:
            let tags = try await provider.generateTags(from: text)
            _ = try annotations.upsert(
                AIAnnotation(itemId: job.itemId, kind: .tags, model: provider.modelName, content: ["tags": tags.joined(separator: ",")])
            )
        case .facts:
            let facts = try await provider.extractFacts(from: text)
            _ = try annotations.upsert(
                AIAnnotation(itemId: job.itemId, kind: .facts, model: provider.modelName, content: ["facts": facts.joined(separator: "\n")])
            )
        case .embedding, .duplicate, .related:
            break
        }
    }
}
