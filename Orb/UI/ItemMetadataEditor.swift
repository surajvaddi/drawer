import Foundation

struct ItemMetadataEditor: Sendable {
    let repository: ItemRepository

    func rename(item: Item, title: String) throws -> Item {
        var updated = item
        updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !updated.title.isEmpty else { throw OrbError.invalidData("Title cannot be empty") }
        return try repository.update(updated)
    }

    func setNote(item: Item, note: String?) throws -> Item {
        var updated = item
        updated.userNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        return try repository.update(updated)
    }
}
