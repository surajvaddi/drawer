import Foundation

struct TextItemProcessor: Sendable {
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

    func process(text: String, sourceApp: String? = nil) throws -> Item {
        let normalized = normalizer.normalize(text)
        let item = Item(
            type: .text,
            title: normalizer.title(from: normalized),
            preview: normalizer.preview(from: normalized),
            contentText: normalized,
            sourceApp: sourceApp
        )
        let saved = try coordinator.saveTextItem(StorageCoordinator.SaveTextItemRequest(item: item))
        _ = try captureEvents.log(CaptureEvent(itemId: saved.id, method: .clipboardSave, sourceApp: sourceApp))
        return saved
    }
}
