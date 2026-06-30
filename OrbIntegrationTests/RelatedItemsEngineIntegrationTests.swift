import XCTest
@testable import Orb

final class RelatedItemsEngineIntegrationTests: XCTestCase {
    func testRelatedItemsShownInDetailView() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let source = try items.create(Item(type: .text, title: "Source", contentText: "machine learning neural networks deep learning"))
        _ = try items.create(Item(type: .text, title: "Related", contentText: "machine learning models neural networks"))
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: source)
        XCTAssertFalse(related.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
