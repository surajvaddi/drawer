import XCTest
@testable import Orb

final class QuickPasteResultsViewIntegrationTests: XCTestCase {
    func testTypeQueryShowsRankedResults() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-qp-results-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "alpha", contentText: "alpha"))
        _ = try items.create(Item(type: .text, title: "beta", contentText: "beta"))
        let results = try SearchRepository(manager: manager).search("alpha")
        XCTAssertEqual(results.first?.title, "alpha")
        manager.close()
    }
}
