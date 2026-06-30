import XCTest
@testable import Orb

final class DocumentChunkerTests: XCTestCase {
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

    func testChunkSizeAndOverlap() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(id: "item-1", type: .text, title: "Chunk test", contentText: "seed"))
        let chunker = DocumentChunker(manager: manager, maxChunkLength: 100)
        let text = String(repeating: "a", count: 250)
        let chunks = try chunker.chunk(itemId: "item-1", text: text)
        XCTAssertGreaterThan(chunks.count, 1)
        XCTAssertLessThanOrEqual(chunks.first?.text.count ?? 0, 100)
    }

    func testChunkLinksToParentItem() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(id: "parent-id", type: .text, title: "Parent", contentText: "seed"))
        let chunker = DocumentChunker(manager: manager, maxChunkLength: 50)
        let chunks = try chunker.chunk(itemId: "parent-id", text: String(repeating: "word ", count: 30))
        XCTAssertTrue(chunks.allSatisfy { $0.itemId == "parent-id" })
    }
}
