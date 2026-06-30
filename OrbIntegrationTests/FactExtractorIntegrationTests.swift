import XCTest
@testable import Orb

final class FactExtractorIntegrationTests: XCTestCase {
    func testExtractFactsEndToEnd() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let text = "Team uses Swift for iOS development\nDeployment happens every Friday\nOn-call rotation is weekly"
        let item = try items.create(Item(type: .text, title: "Notes", contentText: text))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertFalse(facts.isEmpty)
        XCTAssertNotNil(try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .facts))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
