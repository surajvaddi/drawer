import XCTest
@testable import Orb

final class EmbeddingIndexerTests: XCTestCase {
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

    func testIndexerStoresVectorHash() async throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Index", contentText: "searchable content"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let embedding = try await indexer.index(item: item)
        XCTAssertFalse(embedding.textHash.isEmpty)
        XCTAssertNotNil(try StoredEmbeddingRepository(manager: manager).fetch(itemId: item.id, model: embedding.model))
    }

    func testReindexOnContentChange() async throws {
        let items = ItemRepository(manager: manager)
        var item = try items.create(Item(type: .text, title: "Change", contentText: "original text"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let first = try await indexer.index(item: item)
        item.contentText = "updated text content"
        _ = try items.update(item)
        let second = try await indexer.index(item: item)
        XCTAssertNotEqual(first.textHash, second.textHash)
    }
}
