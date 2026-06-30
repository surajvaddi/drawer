import Foundation

struct BlobStore: Sendable {
    let paths: StoragePaths

    struct StoredBlob: Equatable, Sendable {
        let path: String
        let checksum: String
        let sizeBytes: Int64
    }

    func write(data: Data, kind: BlobKind = .original, preferredName: String? = nil) throws -> StoredBlob {
        try paths.ensureDirectoriesExist()
        let directory = paths.blobDirectory(for: kind)
        let fileName = preferredName ?? UUID().uuidString
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return StoredBlob(
            path: fileURL.path,
            checksum: BlobRepository.checksum(for: data),
            sizeBytes: Int64(data.count)
        )
    }

    func read(path: String) throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: path))
    }
}
