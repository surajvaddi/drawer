import Foundation

struct ClipboardSavePipeline: Sendable {
    let coordinator: StorageCoordinator
    let reader: PasteboardReader
    let factory: ItemFactory
    let captureEvents: CaptureEventRepository
    let sourceResolver: SourceAppResolver

    init(
        coordinator: StorageCoordinator,
        reader: PasteboardReader = PasteboardReader(),
        factory: ItemFactory = ItemFactory(),
        captureEvents: CaptureEventRepository? = nil,
        sourceResolver: SourceAppResolver = SourceAppResolver()
    ) {
        self.coordinator = coordinator
        self.reader = reader
        self.factory = factory
        self.captureEvents = captureEvents ?? CaptureEventRepository(manager: coordinator.manager)
        self.sourceResolver = sourceResolver
    }

    @discardableResult
    func saveCurrentClipboard(method: CaptureMethod = .clipboardSave) throws -> Item {
        let pasteboardPayload = reader.read()
        let source = sourceResolver.resolve()
        var capturePayload = factory.makeItem(from: pasteboardPayload, sourceApp: source.name)
        capturePayload.method = method
        capturePayload.sourceApp = source.name
        capturePayload.sourceWindowTitle = source.windowTitle

        let item = factory.makeItem(from: capturePayload)
        let saved: Item
        if let blobData = capturePayload.blobData {
            saved = try coordinator.saveTextItem(
                StorageCoordinator.SaveTextItemRequest(
                    item: item,
                    blobData: blobData,
                    blobKind: .original,
                    mimeType: capturePayload.mimeType ?? "application/octet-stream"
                )
            )
        } else {
            saved = try coordinator.saveTextItem(
                StorageCoordinator.SaveTextItemRequest(item: item)
            )
        }

        _ = try captureEvents.log(
            CaptureEvent(
                itemId: saved.id,
                method: method,
                sourceApp: source.name,
                pasteboardTypes: pasteboardPayload.types,
                rawMetadata: [
                    "bundle_id": source.bundleID ?? "",
                    "window_title": source.windowTitle ?? ""
                ]
            )
        )
        return saved
    }

    @discardableResult
    func saveDragDrop(payload: CapturePayload) throws -> Item {
        let item = factory.makeItem(from: payload)
        let saved = try coordinator.saveTextItem(StorageCoordinator.SaveTextItemRequest(item: item))
        _ = try captureEvents.log(
            CaptureEvent(itemId: saved.id, method: .dragDrop, sourceApp: payload.sourceApp)
        )
        return saved
    }
}
