import XCTest
@testable import Orb

final class LibrarySearchViewTests: XCTestCase {
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

    func testLibrarySearchUsesHybridMerger() async throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "SearchLib", contentText: "library search content"))
        let provider = MockEmbeddingProvider()
        let embeddings = StoredEmbeddingRepository(manager: manager)
        _ = try await EmbeddingIndexer(provider: provider, embeddings: embeddings, items: items, chunker: DocumentChunker(manager: manager)).indexAll(limit: 10)
        let merger = HybridSearchMerger(search: SearchRepository(manager: manager), vectorSearch: VectorSearchRepository(embeddings: embeddings, provider: provider))
        let hits = try await merger.search("SearchLib")
        XCTAssertFalse(hits.isEmpty)
    }
}
