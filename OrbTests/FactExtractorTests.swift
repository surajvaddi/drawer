import XCTest
@testable import Orb

final class FactExtractorTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testExtractFactsFromJobDescription() async throws {
        let items = ItemRepository(manager: manager)
        let jobText = """
        Senior Engineer role at Acme Corp
        Requires 5+ years of Swift experience
        Remote work available with competitive salary
        """
        let item = try items.create(Item(type: .text, title: "Job", contentText: jobText))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertFalse(facts.isEmpty)
    }

    func testFactsLinkToParentItem() async throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Parent", contentText: "Fact one with enough characters here\nFact two with enough characters here"))
        let extractor = FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        )
        let facts = try await extractor.extract(from: item)
        XCTAssertTrue(facts.allSatisfy { $0.sourceItemId == item.id })
    }
}
