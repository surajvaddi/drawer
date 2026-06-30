import Foundation

struct DrawerRowDropHandler: Sendable {
    let moveService: MoveItemToDrawerService

    func drop(itemID: String, onDrawer drawerID: String) throws {
        try moveService.move(itemID: itemID, toDrawer: drawerID)
    }
}
