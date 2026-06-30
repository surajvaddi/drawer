import Foundation

struct DuplicateMergeFlow: Sendable {
    let items: ItemRepository
    let tags: TagRepository
    let deletion: ItemDeletionService

    func merge(primaryID: String, duplicateID: String) throws -> Item {
        guard var primary = try items.fetch(id: primaryID) else {
            throw OrbError.notFound("Primary item not found")
        }
        guard let duplicate = try items.fetch(id: duplicateID) else {
            throw OrbError.notFound("Duplicate item not found")
        }

        if primary.contentText?.isEmpty != false, let text = duplicate.contentText {
            primary.contentText = text
            primary.preview = primary.previewText(from: text)
        }
        if primary.title.isEmpty { primary.title = duplicate.title }
        if primary.userNote?.isEmpty != false, let note = duplicate.userNote {
            primary.userNote = note
        }

        let duplicateTags = try tags.tags(for: duplicateID)
        for tag in duplicateTags {
            try tags.link(itemId: primaryID, tagId: tag.id)
        }

        _ = try items.update(primary)
        try deletion.delete(itemID: duplicateID)
        return primary
    }
}
