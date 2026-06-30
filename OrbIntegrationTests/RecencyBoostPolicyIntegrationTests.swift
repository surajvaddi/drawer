import XCTest
@testable import Orb

final class RecencyBoostPolicyIntegrationTests: XCTestCase {
    func testQuickPasteShowsRecentItemFirst() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-recency-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let old = try items.create(Item(type: .text, title: "Old", lastAccessedAt: Date(timeIntervalSince1970: 1)))
        let recent = try items.create(Item(type: .text, title: "Recent", lastAccessedAt: Date()))
        let ranked = QuickPasteController(items: items, pasteboard: MockPasteboard()).rankedRecents(from: [old, recent])
        XCTAssertEqual(ranked.first?.title, "Recent")
        manager.close()
    }
}
