import XCTest
@testable import Orb

final class SemanticQuickPasteRankerTests: XCTestCase {
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

    func testSemanticScoreBlendedWithRecency() async throws {
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let recent = try items.create(Item(type: .text, title: "Recent", contentText: "swift code snippet"))
        let older = try items.create(Item(type: .text, title: "Older", contentText: "swift code snippet copy"))
        _ = try await indexer.index(item: recent)
        _ = try await indexer.index(item: older)
        let ranker = SemanticQuickPasteRanker(vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let ranked = try await ranker.rank(query: "swift code", candidates: [older, recent], limit: 2)
        XCTAssertEqual(ranked.count, 2)
    }
}
