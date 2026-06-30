import XCTest
@testable import Orb

final class DocumentChunkerIntegrationTests: XCTestCase {
    func testSearchSurfacesBestMatchingChunk() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let longText = "intro section. " + String(repeating: "filler text. ", count: 50) + "needle phrase here. " + String(repeating: "more filler. ", count: 50)
        let item = try items.create(Item(type: .text, title: "LongDoc", contentText: longText))
        let chunks = try DocumentChunker(manager: manager, maxChunkLength: 200).chunk(itemId: item.id, text: longText)
        XCTAssertTrue(chunks.contains { $0.text.contains("needle phrase") })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
