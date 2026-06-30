import Foundation

struct FileReferenceImporter: Sendable {
    let coordinator: StorageCoordinator
    let validator: FileImportValidator
    let captureEvents: CaptureEventRepository

    init(
        coordinator: StorageCoordinator,
        validator: FileImportValidator = FileImportValidator(),
        captureEvents: CaptureEventRepository? = nil
    ) {
        self.coordinator = coordinator
        self.validator = validator
        self.captureEvents = captureEvents ?? CaptureEventRepository(manager: coordinator.manager)
    }

    func importReference(from sourceURL: URL) throws -> (item: Item, bookmark: Data) {
        let validation = try validator.validate(url: sourceURL)
        guard validation.allowed else {
            throw OrbError.invalidData(validation.reason ?? "Import rejected")
        }
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed { sourceURL.stopAccessingSecurityScopedResource() }
        }
        let bookmark = try sourceURL.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        let title = sourceURL.lastPathComponent
        let item = Item(
            type: .file,
            title: title,
            preview: title,
            contentText: sourceURL.path
        )
        let saved = try coordinator.items.create(item)
        _ = try captureEvents.log(CaptureEvent(itemId: saved.id, method: .dragDrop, sourceApp: nil))
        return (saved, bookmark)
    }

    func resolve(bookmark: Data) throws -> URL {
        var stale = false
        let url = try URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
        return url
    }
}
