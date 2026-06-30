import Foundation
import SQLite3

protocol BlobRegistering: Sendable {
    func register(_ blob: Blob) throws -> Blob
}

extension BlobRepository: BlobRegistering {}

struct StorageCoordinator: Sendable {
    let paths: StoragePaths
    let manager: DatabaseManager
    let blobStore: BlobStore
    let items: ItemRepository
    let blobs: any BlobRegistering

    init(paths: StoragePaths, manager: DatabaseManager, blobs: (any BlobRegistering)? = nil) {
        self.paths = paths
        self.manager = manager
        self.blobStore = BlobStore(paths: paths)
        self.items = ItemRepository(manager: manager)
        self.blobs = blobs ?? BlobRepository(manager: manager)
    }

    struct SaveTextItemRequest: Sendable {
        var item: Item
        var blobData: Data?
        var blobKind: BlobKind
        var mimeType: String

        init(item: Item, blobData: Data? = nil, blobKind: BlobKind = .original, mimeType: String = "text/plain") {
            self.item = item
            self.blobData = blobData
            self.blobKind = blobKind
            self.mimeType = mimeType
        }
    }

    func saveTextItem(_ request: SaveTextItemRequest) throws -> Item {
        var writtenPath: String?
        do {
            try manager.exec("BEGIN IMMEDIATE TRANSACTION;")
            if let blobData = request.blobData {
                let stored = try blobStore.write(data: blobData, kind: request.blobKind)
                writtenPath = stored.path
                let savedItem = try items.create(request.item)
                _ = try blobs.register(
                    Blob(
                        itemId: savedItem.id,
                        kind: request.blobKind,
                        localPath: stored.path,
                        mimeType: request.mimeType,
                        sizeBytes: stored.sizeBytes,
                        checksum: stored.checksum
                    )
                )
                try manager.exec("COMMIT;")
                return savedItem
            } else {
                let savedItem = try items.create(request.item)
                try manager.exec("COMMIT;")
                return savedItem
            }
        } catch {
            try? manager.exec("ROLLBACK;")
            if let writtenPath {
                try? FileManager.default.removeItem(atPath: writtenPath)
            }
            throw error
        }
    }

    func ftsRowCount(for itemID: String) throws -> Int {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT COUNT(*) FROM items_fts WHERE item_id = ?;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare fts count failed")
        }
        sqlite3_bind_text(stmt, 1, itemID, -1, SQLITE_TRANSIENT)
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
