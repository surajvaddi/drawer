import XCTest
@testable import Orb

final class EmbeddingIndexerIntegrationTests: XCTestCase {
    func testItemSearchableViaEmbeddingAfterIndex() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Semantic", contentText: "orb knowledge management system"))
        let provider = MockEmbeddingProvider()
        let indexer = EmbeddingIndexer(
            provider: provider,
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        _ = try await indexer.index(item: item)
        let hits = try await VectorSearchRepository(embeddings: StoredEmbeddingRepository(manager: manager), provider: provider).search(query: "knowledge management")
        XCTAssertTrue(hits.contains { $0.itemId == item.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
