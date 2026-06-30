import XCTest
@testable import Orb

final class IndexRebuildServiceTests: XCTestCase {
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

    func testRebuildFTSFromItems() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "RebuildFTS", contentText: "fts content"))
        let service = IndexRebuildService(
            manager: manager,
            indexer: EmbeddingIndexer(
                provider: MockEmbeddingProvider(),
                embeddings: StoredEmbeddingRepository(manager: manager),
                items: items,
                chunker: DocumentChunker(manager: manager)
            )
        )
        let count = try service.rebuildFTS()
        XCTAssertGreaterThan(count, 0)
    }

    func testRebuildEmbeddingsQueue() async throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Embed", contentText: "embedding rebuild"))
        let service = IndexRebuildService(
            manager: manager,
            indexer: EmbeddingIndexer(
                provider: MockEmbeddingProvider(),
                embeddings: StoredEmbeddingRepository(manager: manager),
                items: items,
                chunker: DocumentChunker(manager: manager)
            )
        )
        let count = try await service.rebuildEmbeddings(limit: 10)
        XCTAssertGreaterThan(count, 0)
    }
}
