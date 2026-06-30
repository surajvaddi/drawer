import Foundation

struct LinkItemProcessor: Sendable {
    let coordinator: StorageCoordinator
    let metadataFetcher: any LinkMetadataFetching
    let captureEvents: CaptureEventRepository

    init(
        coordinator: StorageCoordinator,
        metadataFetcher: any LinkMetadataFetching = LinkMetadataFetcher(),
        captureEvents: CaptureEventRepository? = nil
    ) {
        self.coordinator = coordinator
        self.metadataFetcher = metadataFetcher
        self.captureEvents = captureEvents ?? CaptureEventRepository(manager: coordinator.manager)
    }

    func process(urlString: String, sourceApp: String? = nil) async throws -> Item {
        let normalized = URLNormalizer.normalize(urlString)
        let metadata = try? await metadataFetcher.fetchMetadata(for: normalized)
        let title = metadata?.title?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? URLNormalizer.domain(from: normalized)
            ?? normalized
        let item = Item(
            type: .url,
            title: title,
            preview: normalized,
            contentText: normalized,
            sourceURL: normalized,
            sourceApp: sourceApp
        )
        let saved = try coordinator.saveTextItem(StorageCoordinator.SaveTextItemRequest(item: item))
        _ = try captureEvents.log(CaptureEvent(itemId: saved.id, method: .clipboardSave, sourceApp: sourceApp))
        return saved
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
