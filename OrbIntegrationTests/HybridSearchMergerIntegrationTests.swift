import XCTest
@testable import Orb

final class HybridSearchMergerIntegrationTests: XCTestCase {
    func testConceptualQueryRanksSemanticMatch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let match = try items.create(Item(type: .text, title: "Budget", contentText: "quarterly financial planning spreadsheet"))
        _ = try await indexer.index(item: match)
        let merger = HybridSearchMerger(search: SearchRepository(manager: manager), vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let hits = try await merger.search("financial planning", limit: 5)
        XCTAssertTrue(hits.contains { $0.itemId == match.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
