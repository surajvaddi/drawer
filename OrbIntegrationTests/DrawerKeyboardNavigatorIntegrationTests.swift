import XCTest
@testable import Orb

final class DrawerKeyboardNavigatorIntegrationTests: XCTestCase {
    func testKeyboardOnlyRetrieveItemFlow() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-kb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let itemsRepo = ItemRepository(manager: manager)
        let saved = try itemsRepo.create(Item(type: .text, title: "Pick me", contentText: "Pick me"))
        let items = try itemsRepo.listRecent()
        var navigator = DrawerKeyboardNavigator()
        navigator.moveDown(itemCount: items.count)
        let selected = navigator.selectedItem(in: items)
        XCTAssertEqual(selected?.id, saved.id)
        let pasteboard = MockPasteboard()
        TextItemActions(pasteboard: pasteboard, repository: itemsRepo).copyPlainText(saved)
        XCTAssertEqual(pasteboard.string(forType: .string), "Pick me")
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
