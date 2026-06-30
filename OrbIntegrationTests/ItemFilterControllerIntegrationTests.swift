import XCTest
@testable import Orb

final class ItemFilterControllerIntegrationTests: XCTestCase {
    func testCombinedTagAndTypeFilters() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-combo-filter-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = [Item(type: .screenshot, title: "s", sourceApp: "Safari"), Item(type: .text, title: "t", sourceApp: "Safari")]
        var typeFilter = ItemFilterController()
        typeFilter.criteria.types = [.screenshot]
        var sourceFilter = ItemFilterController()
        sourceFilter.criteria.sourceApps = ["safari"]
        let typed = typeFilter.filter(items)
        let combined = sourceFilter.filter(typed)
        XCTAssertEqual(combined.count, 1)
        manager.close()
    }
}
