import Foundation

struct BulkItemActions: Sendable {
    let items: ItemRepository
    let blobs: BlobRepository
    let blobStore: BlobStore

    func archive(itemIDs: [String]) throws {
        try items.bulkArchive(ids: itemIDs)
    }

    func delete(itemIDs: [String]) throws {
        var paths: [String] = []
        for id in itemIDs {
            let blobRows = try blobs.deleteForItem(itemId: id)
            paths.append(contentsOf: blobRows.map(\.localPath))
        }
        try items.bulkDelete(ids: itemIDs)
        for path in paths {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}
