import Foundation

struct ScreenshotSavePipeline: Sendable {
    let coordinator: StorageCoordinator
    let thumbnailGenerator: ThumbnailGenerator
    let captureEvents: CaptureEventRepository

    init(
        coordinator: StorageCoordinator,
        thumbnailGenerator: ThumbnailGenerator = ThumbnailGenerator(),
        captureEvents: CaptureEventRepository? = nil
    ) {
        self.coordinator = coordinator
        self.thumbnailGenerator = thumbnailGenerator
        self.captureEvents = captureEvents ?? CaptureEventRepository(manager: coordinator.manager)
    }

    func save(imageData: Data, title: String = "Screenshot", sourceApp: String? = nil) throws -> Item {
        let item = Item(
            type: .screenshot,
            title: title,
            preview: "Screenshot",
            sourceApp: sourceApp
        )
        let thumbnail = try thumbnailGenerator.generatePNG(from: imageData)
        var writtenPaths: [String] = []
        do {
            try coordinator.manager.exec("BEGIN IMMEDIATE TRANSACTION;")
            let original = try coordinator.blobStore.write(data: imageData, kind: .original, preferredName: "\(item.id).png")
            writtenPaths.append(original.path)
            let savedItem = try coordinator.items.create(item)
            _ = try coordinator.blobs.register(
                Blob(
                    itemId: savedItem.id,
                    kind: .original,
                    localPath: original.path,
                    mimeType: "image/png",
                    sizeBytes: original.sizeBytes,
                    checksum: original.checksum
                )
            )
            let thumbStored = try coordinator.blobStore.write(data: thumbnail, kind: .thumbnail, preferredName: "\(savedItem.id).png")
            writtenPaths.append(thumbStored.path)
            _ = try coordinator.blobs.register(
                Blob(
                    itemId: savedItem.id,
                    kind: .thumbnail,
                    localPath: thumbStored.path,
                    mimeType: "image/png",
                    sizeBytes: thumbStored.sizeBytes,
                    checksum: thumbStored.checksum
                )
            )
            try coordinator.manager.exec("COMMIT;")
            _ = try captureEvents.log(CaptureEvent(itemId: savedItem.id, method: .screenshot, sourceApp: sourceApp))
            return savedItem
        } catch {
            try? coordinator.manager.exec("ROLLBACK;")
            for path in writtenPaths {
                try? FileManager.default.removeItem(atPath: path)
            }
            throw error
        }
    }
}
