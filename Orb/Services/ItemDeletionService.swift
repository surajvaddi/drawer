import Foundation

struct ItemDeletionService: Sendable {
    let items: ItemRepository
    let blobs: BlobRepository
    let annotations: AIAnnotationRepository
    let blobStore: BlobStore

    func delete(itemID: String) throws {
        let blobRows = try blobs.deleteForItem(itemId: itemID)
        try annotations.delete(itemId: itemID)
        try items.delete(id: itemID)
        for blob in blobRows {
            try? FileManager.default.removeItem(atPath: blob.localPath)
        }
    }

    func delete(itemIDs: [String]) throws {
        for id in itemIDs {
            try delete(itemID: id)
        }
    }
}
