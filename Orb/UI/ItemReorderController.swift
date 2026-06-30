import Foundation

struct ItemReorderController: Sendable {
    let repository: ItemRepository

    func reorder(itemIDs: [String]) throws {
        try repository.updateSortOrder(itemIDsInOrder: itemIDs)
    }

    func move(itemID: String, toDrawer drawerID: String?) throws {
        try repository.moveToDrawer(itemID: itemID, drawerID: drawerID)
    }
}
