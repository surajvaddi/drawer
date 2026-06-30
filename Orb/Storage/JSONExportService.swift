import Foundation

struct JSONExportPayload: Codable, Sendable {
    var exportedAt: Date
    var items: [Item]
    var drawers: [Drawer]
    var tags: [Tag]
}

struct JSONExportService: Sendable {
    let items: ItemRepository
    let drawers: DrawerRepository
    let tags: TagRepository

    func export() throws -> Data {
        let payload = JSONExportPayload(
            exportedAt: Date(),
            items: try items.listAll(includeArchived: true),
            drawers: try drawers.fetchAll(),
            tags: try tags.fetchAll()
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    func export(to url: URL) throws {
        try export().write(to: url, options: .atomic)
    }
}
