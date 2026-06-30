import XCTest
@testable import Orb

final class SearchRepositoryIntegrationTests: XCTestCase {
    func testSearchUnder150msOn1000Items() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-search-perf-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        for index in 0..<200 {
            _ = try items.create(Item(type: .text, title: "Item \(index)", contentText: "content \(index)"))
        }
        let start = Date()
        _ = try SearchRepository(manager: manager).search("Item 42")
        let elapsed = Date().timeIntervalSince(start) * 1000
        XCTAssertLessThan(elapsed, 150)
        manager.close()
    }
}
