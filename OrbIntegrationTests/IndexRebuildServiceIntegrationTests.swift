import XCTest
@testable import Orb

final class IndexRebuildServiceIntegrationTests: XCTestCase {
    func testIndexRebuildRestoresSearch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Searchable", contentText: "unique rebuild term"))
        let indexer = EmbeddingIndexer(
            provider: MockEmbeddingProvider(),
            embeddings: StoredEmbeddingRepository(manager: manager),
            items: items,
            chunker: DocumentChunker(manager: manager)
        )
        let service = IndexRebuildService(manager: manager, indexer: indexer)
        _ = try service.rebuildFTS()
        let results = try SearchRepository(manager: manager).search("unique rebuild term")
        XCTAssertFalse(results.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
