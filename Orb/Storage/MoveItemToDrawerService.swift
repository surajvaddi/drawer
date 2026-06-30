import Foundation

struct MoveItemToDrawerService: Sendable {
    let items: ItemRepository

    func move(itemID: String, toDrawer drawerID: String?) throws {
        let target = drawerID ?? DefaultDataSeeder.inboxDrawerID
        try items.moveToDrawer(itemID: itemID, drawerID: target)
    }
}
