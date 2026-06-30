import Foundation

struct StoragePaths: Sendable {
    let root: URL

    init(root: URL? = nil) {
        if let root {
            self.root = root
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            self.root = appSupport.appendingPathComponent("Orb", isDirectory: true)
        }
    }

    var databaseURL: URL { root.appendingPathComponent("orb.sqlite") }
    var blobsURL: URL { root.appendingPathComponent("blobs", isDirectory: true) }
    var indexesURL: URL { root.appendingPathComponent("indexes", isDirectory: true) }
    var backupsURL: URL { root.appendingPathComponent("backups", isDirectory: true) }
    var logsURL: URL { root.appendingPathComponent("logs", isDirectory: true) }

    func blobDirectory(for kind: BlobKind) -> URL {
        blobsURL.appendingPathComponent(kind.folderName, isDirectory: true)
    }

    @discardableResult
    func ensureDirectoriesExist() throws -> StoragePaths {
        let fm = FileManager.default
        let directories = [
            root,
            blobsURL,
            indexesURL,
            backupsURL,
            logsURL
        ] + BlobKind.allCases.map { blobDirectory(for: $0) }

        for directory in directories {
            try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return self
    }
}
