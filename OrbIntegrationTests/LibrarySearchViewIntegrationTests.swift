import XCTest
@testable import Orb

final class LibrarySearchViewIntegrationTests: XCTestCase {
    func testAdvancedSearchAcrossEntireLibrary() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Alpha", contentText: "alpha content"))
        _ = try items.create(Item(type: .text, title: "Beta", contentText: "beta content"))
        let results = try SearchRepository(manager: manager).search("Alpha")
        XCTAssertFalse(results.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
