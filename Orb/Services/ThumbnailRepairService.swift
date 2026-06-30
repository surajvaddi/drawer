import Foundation

struct ThumbnailRepairService: Sendable {
    let items: ItemRepository
    let blobs: BlobRepository
    let blobStore: BlobStore
    let generator: ThumbnailGenerator

    func repairMissing(limit: Int = 50) throws -> Int {
        let recent = try items.listRecent(limit: limit)
        var repaired = 0
        for item in recent where item.type == .image || item.type == .screenshot {
            let existing = try blobs.list(itemId: item.id)
            let hasThumbnail = existing.contains { $0.kind == .thumbnail }
            guard !hasThumbnail, let original = existing.first(where: { $0.kind == .original }) else { continue }
            let data = try Data(contentsOf: URL(fileURLWithPath: original.localPath))
            let png = try generator.generatePNG(from: data)
            let stored = try blobStore.write(data: png, kind: .thumbnail, preferredName: "\(item.id).png")
            _ = try blobs.register(
                Blob(
                    itemId: item.id,
                    kind: .thumbnail,
                    localPath: stored.path,
                    mimeType: "image/png",
                    sizeBytes: stored.sizeBytes,
                    checksum: stored.checksum
                )
            )
            repaired += 1
        }
        return repaired
    }
}
