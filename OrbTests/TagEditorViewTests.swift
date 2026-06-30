import XCTest
@testable import Orb

final class TagEditorViewTests: XCTestCase {
    private var manager: DatabaseManager!
    private var controller: TagEditorController!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-tag-edit-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        controller = TagEditorController(tags: TagRepository(manager: manager))
    }

    override func tearDownWithError() throws { manager.close() }

    func testAddTagCreatesTagRecord() throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Tagged"))
        let tag = try controller.addTag(name: "Design", to: item.id)
        XCTAssertEqual(tag.name, "design")
        XCTAssertEqual(try TagRepository(manager: manager).tags(for: item.id).count, 1)
    }

    func testAutocompleteFiltersExisting() throws {
        let tags = TagRepository(manager: manager)
        _ = try tags.create(name: "design")
        _ = try tags.create(name: "debug")
        let suggestions = try controller.autocomplete(query: "de", existing: [])
        XCTAssertTrue(suggestions.contains(where: { $0.name == "design" }))
    }
}
