import XCTest
@testable import Orb

final class DrawerSearchControllerTests: XCTestCase {
    func testDebounceSearchInput() {
        let controller = DrawerSearchController(
            search: SearchRepository(manager: DatabaseManager(paths: StoragePaths(root: FileManager.default.temporaryDirectory)))
        )
        XCTAssertGreaterThan(controller.debounceInterval(), 0)
    }

    func testEmptyQueryShowsRecents() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drawer-search-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let recents = try ItemRepository(manager: manager).listRecent()
        let controller = DrawerSearchController(search: SearchRepository(manager: manager))
        let results = try controller.results(for: "", recents: recents)
        XCTAssertEqual(results, recents)
        manager.close()
    }
}
