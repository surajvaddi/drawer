import XCTest
@testable import Orb

final class LibraryWindowIntegrationTests: XCTestCase {
    func testLibraryShowsAllDrawersAndItems() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(
            drawers: DrawerRepository(manager: manager),
            defaults: UserDefaults(suiteName: "orb.lib.int.\(UUID().uuidString)")!
        ).seedIfNeeded()
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let saved = try items.create(
            Item(type: .text, title: "LibItem", contentText: "x", drawerId: DefaultDataSeeder.inboxDrawerID)
        )
        let allItems = try items.listAll()
        let allDrawers = try drawers.fetchAll()
        XCTAssertTrue(allItems.contains { $0.id == saved.id })
        XCTAssertTrue(allDrawers.contains { $0.id == DefaultDataSeeder.inboxDrawerID })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
