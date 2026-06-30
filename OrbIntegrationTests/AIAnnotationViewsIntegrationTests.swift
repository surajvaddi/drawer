import XCTest
@testable import Orb

final class AIAnnotationViewsIntegrationTests: XCTestCase {
    func testAIAnnotationsVisibleOnItemDetail() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Detail", contentText: "visible content"))
        let annotations = AIAnnotationRepository(manager: manager)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .summary, model: "mock-orb-v1", content: ["value": "A summary"])
        )
        let fetched = try annotations.fetchAll(itemId: item.id)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.kind, .summary)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
