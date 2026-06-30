import XCTest
@testable import Orb

final class TagFilterControllerIntegrationTests: XCTestCase {
    func testTagFilterWorksWithInboxAndDrawers() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-tag-filter-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let a = try items.create(Item(type: .text, title: "A"))
        _ = try items.create(Item(type: .text, title: "B"))
        let tag = try tags.create(name: "work")
        try tags.link(itemId: a.id, tagId: tag.id)
        let ids = Set(try tags.itemIDs(withTagID: tag.id))
        let filtered = TagFilterController(selectedTagID: tag.id).filter(items: try items.listAll(), tagItemIDs: ids)
        XCTAssertEqual(filtered.count, 1)
        manager.close()
    }
}
