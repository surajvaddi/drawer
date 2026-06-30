import XCTest
@testable import Orb

final class RelatedItemsEngineTests: XCTestCase {
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

    func testRelatedBySharedTags() async throws {
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let tag = try tags.create(name: "swift")
        let a = try items.create(Item(type: .text, title: "Swift Guide", contentText: "swift programming language guide"))
        let b = try items.create(Item(type: .text, title: "Swift Tips", contentText: "swift programming tips and tricks"))
        try tags.link(itemId: a.id, tagId: tag.id)
        try tags.link(itemId: b.id, tagId: tag.id)
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: a)
        XCTAssertTrue(related.contains { $0.itemId == b.id })
    }

    func testRelatedBySameSourceURL() async throws {
        let items = ItemRepository(manager: manager)
        let url = "https://docs.example.com/guide"
        let a = try items.create(Item(type: .url, title: "Guide Part 1", contentText: "documentation guide part one", sourceURL: url))
        let b = try items.create(Item(type: .url, title: "Guide Part 2", contentText: "documentation guide part two", sourceURL: url))
        let engine = RelatedItemsEngine(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager))
        let related = try await engine.related(to: a)
        XCTAssertFalse(related.isEmpty)
    }
}
