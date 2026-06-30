import Foundation

struct TagGenerator: Sendable {
    let provider: AIProvider
    let annotations: AIAnnotationRepository
    let tags: TagRepository
    let queue: AIJobQueue

    func generate(for item: Item) async throws -> [Tag] {
        let text = item.contentText ?? item.preview
        let names = try await provider.generateTags(from: text)
        var linked: [Tag] = []
        for name in names {
            let tag = try tags.create(name: name)
            try tags.link(itemId: item.id, tagId: tag.id)
            linked.append(tag)
        }
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .tags, model: provider.modelName, content: ["tags": names.joined(separator: ",")])
        )
        return linked
    }

    func enqueue(for itemId: String) throws -> AIJob {
        try queue.enqueue(itemId: itemId, kind: .tags)
    }
}
