import XCTest
@testable import Orb

final class SemanticQuickPasteRankerIntegrationTests: XCTestCase {
    func testQuickPasteFindsVagueConceptualQuery() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Notes", contentText: "team standup meeting action items"))
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).index(item: item)
        let candidates = try items.listRecent()
        let ranked = try await SemanticQuickPasteRanker(vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider)).rank(query: "meeting actions", candidates: candidates)
        XCTAssertTrue(ranked.contains { $0.id == item.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
