import XCTest
@testable import Orb

final class TagRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var items: ItemRepository!
    private var tags: TagRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-tag-repo-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        items = ItemRepository(manager: manager)
        tags = TagRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testLinkTagToItem() throws {
        let item = try items.create(Item(type: .text, title: "Note"))
        let tag = try tags.create(name: "research")
        try tags.link(itemId: item.id, tagId: tag.id)
        let linked = try tags.tags(for: item.id)
        XCTAssertEqual(linked.count, 1)
        XCTAssertEqual(linked.first?.name, "research")
    }

    func testTagNameDedupedOnCreate() throws {
        let first = try tags.create(name: "Concrete")
        let second = try tags.create(name: "  concrete  ")
        XCTAssertEqual(first.id, second.id)
    }
}
