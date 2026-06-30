import XCTest
@testable import Orb

final class SearchFilterParserIntegrationTests: XCTestCase {
    func testCombinedFiltersNarrowResults() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-filter-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .screenshot, title: "design shot", contentText: "design"))
        _ = try items.create(Item(type: .text, title: "design note", contentText: "design"))
        let results = try SearchRepository(manager: manager).search("type:screenshot design")
        XCTAssertTrue(results.allSatisfy { $0.type == .screenshot })
        manager.close()
    }
}
