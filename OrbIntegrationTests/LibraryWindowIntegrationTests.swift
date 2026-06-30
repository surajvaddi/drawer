import XCTest
@testable import Orb

final class LibraryWindowIntegrationTests: XCTestCase {
    func testLibraryShowsAllDrawersAndItems() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "LibItem", contentText: "x"))
        let allItems = try items.listAll()
        let allDrawers = try drawers.fetchAll()
        XCTAssertFalse(allItems.isEmpty)
        XCTAssertFalse(allDrawers.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
