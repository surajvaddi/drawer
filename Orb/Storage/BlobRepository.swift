import Foundation
import SQLite3
import CryptoKit

struct BlobRepository: Sendable {
    let manager: DatabaseManager

    func register(_ blob: Blob) throws -> Blob {
        try manager.exec(
            """
            INSERT INTO blobs (
              id, item_id, kind, local_path, mime_type, size_bytes, checksum, created_at
            ) VALUES (
              '\(escape(blob.id))',
              '\(escape(blob.itemId))',
              '\(escape(blob.kind.rawValue))',
              '\(escape(blob.localPath))',
              '\(escape(blob.mimeType))',
              \(blob.sizeBytes),
              '\(escape(blob.checksum))',
              '\(DBDateCodec.string(from: blob.createdAt))'
            );
            """
        )
        return blob
    }

    func list(itemId: String, kind: BlobKind? = nil) throws -> [Blob] {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql: String
        if let kind {
            sql = "SELECT * FROM blobs WHERE item_id = ? AND kind = ? ORDER BY created_at DESC;"
        } else {
            sql = "SELECT * FROM blobs WHERE item_id = ? ORDER BY created_at DESC;"
        }
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare list blobs failed")
        }
        sqlite3_bind_text(stmt, 1, itemId, -1, SQLITE_TRANSIENT)
        if let kind {
            sqlite3_bind_text(stmt, 2, kind.rawValue, -1, SQLITE_TRANSIENT)
        }
        var blobs: [Blob] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            blobs.append(try mapRow(stmt))
        }
        return blobs
    }

    static func checksum(for data: Data) -> String {
        SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> Blob {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let itemId = text(1),
            let kindRaw = text(2),
            let kind = BlobKind(rawValue: kindRaw),
            let localPath = text(3),
            let mimeType = text(4),
            let checksum = text(6),
            let createdRaw = text(7)
        else { throw OrbError.storage("invalid blob row") }
        return Blob(
            id: id,
            itemId: itemId,
            kind: kind,
            localPath: localPath,
            mimeType: mimeType,
            sizeBytes: sqlite3_column_int64(stmt, 5),
            checksum: checksum,
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date()
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
