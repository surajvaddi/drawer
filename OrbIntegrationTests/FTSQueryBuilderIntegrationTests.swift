import XCTest
@testable import Orb

final class FTSQueryBuilderIntegrationTests: XCTestCase {
    func testFTSQueryReturnsExpectedHits() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-fts-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try ItemRepository(manager: manager).create(Item(type: .text, title: "Design system", contentText: "modal patterns"))
        let results = try SearchRepository(manager: manager).search("design")
        XCTAssertFalse(results.isEmpty)
        manager.close()
    }
}
