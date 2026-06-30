import Foundation

struct FileImporter: Sendable {
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

    func importCopy(from sourceURL: URL) throws -> Item {
        let validation = try validator.validate(url: sourceURL)
        guard validation.allowed else {
            throw OrbError.invalidData(validation.reason ?? "Import rejected")
        }
        let data = try Data(contentsOf: sourceURL)
        let title = sourceURL.lastPathComponent
        let item = Item(
            type: .file,
            title: title,
            preview: title,
            contentText: title
        )
        let stored = try coordinator.blobStore.write(data: data, kind: .original, preferredName: title)
        var writtenPath = stored.path
        do {
            try coordinator.manager.exec("BEGIN IMMEDIATE TRANSACTION;")
            let saved = try coordinator.items.create(item)
            _ = try coordinator.blobs.register(
                Blob(
                    itemId: saved.id,
                    kind: .original,
                    localPath: stored.path,
                    mimeType: mimeType(for: sourceURL),
                    sizeBytes: stored.sizeBytes,
                    checksum: stored.checksum
                )
            )
            try coordinator.manager.exec("COMMIT;")
            _ = try captureEvents.log(CaptureEvent(itemId: saved.id, method: .dragDrop, sourceApp: nil))
            return saved
        } catch {
            try? coordinator.manager.exec("ROLLBACK;")
            try? FileManager.default.removeItem(atPath: writtenPath)
            throw error
        }
    }

    private func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "md", "markdown", "txt", "csv": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}
