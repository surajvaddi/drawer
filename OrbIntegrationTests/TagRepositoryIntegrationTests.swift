import XCTest
@testable import Orb

final class TagRepositoryIntegrationTests: XCTestCase {
    func testItemTagsSurviveItemUpdate() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-tag-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        var item = try items.create(Item(type: .text, title: "Original"))
        let tag = try tags.create(name: "jobs")
        try tags.link(itemId: item.id, tagId: tag.id)
        item.title = "Updated"
        _ = try items.update(item)
        let linked = try tags.tags(for: item.id)
        XCTAssertEqual(linked.map(\.name), ["jobs"])
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
