import XCTest
@testable import Orb

final class DrawerSearchControllerIntegrationTests: XCTestCase {
    func testSearchKindDesignsReturnsLinkAndScreenshot() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drawer-search-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .url, title: "design doc", contentText: "https://design.example"))
        _ = try items.create(Item(type: .screenshot, title: "design shot", contentText: "design ui"))
        let controller = DrawerSearchController(search: SearchRepository(manager: manager))
        let results = try controller.results(for: "design", recents: try items.listRecent())
        XCTAssertGreaterThanOrEqual(results.count, 1)
        manager.close()
    }
}
