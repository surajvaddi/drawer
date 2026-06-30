import Foundation

struct OCRIndexer: Sendable {
    let coordinator: StorageCoordinator
    let ocrService: any OCRRecognizing
    let items: ItemRepository

    init(coordinator: StorageCoordinator, ocrService: any OCRRecognizing = OCRService(), items: ItemRepository? = nil) {
        self.coordinator = coordinator
        self.ocrService = ocrService
        self.items = items ?? coordinator.items
    }

    @discardableResult
    func index(item: Item, imageData: Data) throws -> Item {
        let text = try ocrService.recognizeText(in: imageData)
        guard !text.isEmpty else { return item }
        let ocrData = Data(text.utf8)
        let stored = try coordinator.blobStore.write(data: ocrData, kind: .ocr, preferredName: "\(item.id).txt")
        _ = try coordinator.blobs.register(
            Blob(
                itemId: item.id,
                kind: .ocr,
                localPath: stored.path,
                mimeType: "text/plain",
                sizeBytes: stored.sizeBytes,
                checksum: stored.checksum
            )
        )
        var updated = item
        updated.contentText = [item.contentText, text].compactMap { $0?.isEmpty == false ? $0 : nil }.joined(separator: "\n")
        updated.preview = updated.previewText(from: text)
        return try items.update(updated)
    }

    func searchIndexedText(manager: DatabaseManager, query: String) throws -> [String] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT item_id FROM items_fts WHERE items_fts MATCH ?;"
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare OCR search failed")
        }
        sqlite3_bind_text(stmt, 1, query, -1, SQLITE_TRANSIENT)
        var ids: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            if let c = sqlite3_column_text(stmt, 0) {
                ids.append(String(cString: c))
            }
        }
        return ids
    }
}

import SQLite3

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
