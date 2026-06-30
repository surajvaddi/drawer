import XCTest
@testable import Orb

final class HybridSearchMergerTests: XCTestCase {
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

    func testMergerDeduplicatesItems() async throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "HybridTarget", contentText: "hybrid search target content"))
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).index(item: item)
        let merger = HybridSearchMerger(
            search: SearchRepository(manager: manager),
            vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider)
        )
        let hits = try await merger.search("HybridTarget", limit: 10)
        let ids = hits.map(\.itemId)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testSemanticWeightApplied() async throws {
        let hit = HybridSearchHit(itemId: "a", ftsScore: 10, vectorScore: 5)
        XCTAssertEqual(hit.combinedScore, 10 * 0.6 + 5 * 0.4, accuracy: 0.001)
    }
}
