import XCTest
@testable import Orb

final class TagEditorViewIntegrationTests: XCTestCase {
    func testTagsPersistAndDisplayOnCard() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-tag-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Card"))
        let tag = try TagEditorController(tags: TagRepository(manager: manager)).addTag(name: "design", to: item.id)
        XCTAssertEqual(try TagRepository(manager: manager).tags(for: item.id).first?.id, tag.id)
        manager.close()
    }
}
