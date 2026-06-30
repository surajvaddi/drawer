import XCTest
@testable import Orb

final class DrawerSuggestionBannerTests: XCTestCase {
    func testAcceptAppliesDrawerToItem() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-suggest-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Jobs"))
        let item = try items.create(Item(type: .url, title: "Role"))
        let controller = DrawerSuggestionController(moveService: MoveItemToDrawerService(items: items))
        try controller.accept(itemID: item.id, suggestion: DrawerSuggestion(drawerID: drawer.id, drawerName: drawer.name, ruleName: "Jobs"))
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, drawer.id)
        manager.close()
    }

    func testDismissLeavesInbox() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-dismiss-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Stay", drawerId: DefaultDataSeeder.inboxDrawerID))
        DrawerSuggestionController(moveService: MoveItemToDrawerService(items: items)).dismiss()
        XCTAssertEqual(try items.fetch(id: item.id)?.drawerId, DefaultDataSeeder.inboxDrawerID)
        manager.close()
    }
}
