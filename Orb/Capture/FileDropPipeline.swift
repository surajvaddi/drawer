import Foundation

struct FileDropPipeline: Sendable {
    let importer: FileImporter
    let referenceImporter: FileReferenceImporter
    var useReferenceImport: Bool

    init(coordinator: StorageCoordinator, useReferenceImport: Bool = false) {
        self.importer = FileImporter(coordinator: coordinator)
        self.referenceImporter = FileReferenceImporter(coordinator: coordinator)
        self.useReferenceImport = useReferenceImport
    }

    func importURLs(_ urls: [URL]) throws -> [Item] {
        try urls.map { url in
            if useReferenceImport {
                return try referenceImporter.importReference(from: url).item
            }
            return try importer.importCopy(from: url)
        }
    }
}
