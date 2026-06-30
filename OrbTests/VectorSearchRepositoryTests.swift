import XCTest
@testable import Orb

final class VectorSearchRepositoryTests: XCTestCase {
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

    func testCosineSimilarityRanking() async throws {
        let items = ItemRepository(manager: manager)
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let a = try items.create(Item(type: .text, title: "A", contentText: "swift programming"))
        let b = try items.create(Item(type: .text, title: "B", contentText: "swift programming language"))
        let c = try items.create(Item(type: .text, title: "C", contentText: "unrelated cooking recipes"))
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        _ = try await indexer.index(item: a)
        _ = try await indexer.index(item: b)
        _ = try await indexer.index(item: c)
        let repo = VectorSearchRepository(embeddings: embeddings, provider: provider)
        let hits = try await repo.search(query: "swift programming", limit: 3)
        XCTAssertGreaterThanOrEqual(hits.count, 2)
        if hits.count >= 2 {
            XCTAssertGreaterThanOrEqual(hits[0].score, hits[1].score)
        }
    }

    func testMinScoreThreshold() async throws {
        let items = ItemRepository(manager: manager)
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let item = try items.create(Item(type: .text, title: "One", contentText: "unique content alpha"))
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        _ = try await indexer.index(item: item)
        let repo = VectorSearchRepository(embeddings: embeddings, provider: provider)
        let hits = try await repo.search(query: "completely unrelated zebra furniture", limit: 10)
        let topScore = hits.first?.score ?? 0
        XCTAssertLessThan(topScore, 0.99)
    }
}
