import Foundation

struct ThumbnailCacheEvictor: Sendable {
    let paths: StoragePaths
    let maxBytes: Int64

    func evictIfNeeded() throws {
        let directory = paths.blobDirectory(for: .thumbnail)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey])
        let sized = try files.map { url -> (URL, Int64, Date) in
            let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            return (url, Int64(values.fileSize ?? 0), values.contentModificationDate ?? .distantPast)
        }
        let total = sized.reduce(0) { $0 + $1.1 }
        guard total > maxBytes else { return }
        for entry in sized.sorted(by: { $0.2 < $1.2 }) {
            try? FileManager.default.removeItem(at: entry.0)
        }
    }
}
