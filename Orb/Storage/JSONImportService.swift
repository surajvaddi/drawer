import Foundation

struct JSONImportService: Sendable {
    let items: ItemRepository
    let drawers: DrawerRepository
    let tags: TagRepository

    func importData(_ data: Data, merge: Bool = true) throws -> JSONImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(JSONExportPayload.self, from: data)
        var importedItems = 0
        var importedDrawers = 0
        var importedTags = 0

        if merge {
            for drawer in payload.drawers {
                if try drawers.fetch(id: drawer.id) == nil {
                    _ = try drawers.create(drawer)
                    importedDrawers += 1
                }
            }
            for tag in payload.tags {
                _ = try tags.create(name: tag.name, color: tag.color)
                importedTags += 1
            }
            for item in payload.items {
                if try items.fetch(id: item.id) == nil {
                    _ = try items.create(item)
                    importedItems += 1
                }
            }
        } else {
            for drawer in payload.drawers {
                if try drawers.fetch(id: drawer.id) == nil {
                    _ = try drawers.create(drawer)
                    importedDrawers += 1
                }
            }
            for tag in payload.tags {
                _ = try tags.create(name: tag.name, color: tag.color)
                importedTags += 1
            }
            for item in payload.items {
                _ = try items.create(item)
                importedItems += 1
            }
        }

        return JSONImportResult(items: importedItems, drawers: importedDrawers, tags: importedTags)
    }

    func importFile(at url: URL, merge: Bool = true) throws -> JSONImportResult {
        try importData(Data(contentsOf: url), merge: merge)
    }
}

struct JSONImportResult: Equatable, Sendable {
    var items: Int
    var drawers: Int
    var tags: Int
}
