import XCTest
@testable import Orb

final class VectorSearchRepositoryIntegrationTests: XCTestCase {
    func testSemanticQueryFindsRelatedConcreteItems() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let indexer = EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager))
        let target = try items.create(Item(type: .text, title: "Invoice", contentText: "invoice number 42 from acme"))
        _ = try items.create(Item(type: .text, title: "Other", contentText: "weather forecast sunny"))
        _ = try await indexer.index(item: target)
        let hits = try await VectorSearchRepository(embeddings: embeddings, provider: provider).search(query: "invoice acme")
        XCTAssertTrue(hits.contains { $0.itemId == target.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
