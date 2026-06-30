import Foundation

struct RichClipProcessor: Sendable {
    let coordinator: StorageCoordinator
    let normalizer: TextNormalizer
    let captureEvents: CaptureEventRepository

    init(
        coordinator: StorageCoordinator,
        normalizer: TextNormalizer = TextNormalizer(),
        captureEvents: CaptureEventRepository? = nil
    ) {
        self.coordinator = coordinator
        self.normalizer = normalizer
        self.captureEvents = captureEvents ?? CaptureEventRepository(manager: coordinator.manager)
    }

    func process(plainText: String, html: String?, sourceApp: String? = nil) throws -> Item {
        let text = normalizer.normalize(plainText)
        let item = Item(
            type: .richClip,
            title: normalizer.title(from: text),
            preview: stripHTMLForPreview(html) ?? normalizer.preview(from: text),
            contentText: text,
            contentHTML: html,
            sourceApp: sourceApp
        )
        let saved = try coordinator.saveTextItem(StorageCoordinator.SaveTextItemRequest(item: item))
        _ = try captureEvents.log(CaptureEvent(itemId: saved.id, method: .clipboardSave, sourceApp: sourceApp))
        return saved
    }

    func stripHTMLForPreview(_ html: String?) -> String? {
        guard let html else { return nil }
        let stripped = html
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
        let normalized = normalizer.normalize(stripped)
        return normalized.isEmpty ? nil : normalizer.preview(from: normalized)
    }
}
