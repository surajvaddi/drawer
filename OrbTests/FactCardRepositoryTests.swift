import XCTest
@testable import Orb

final class FactCardRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var repository: FactCardRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-fact-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = FactCardRepository(items: ItemRepository(manager: manager))
    }

    override func tearDownWithError() throws { manager.close() }

    func testCreateFactLinksSourceItem() throws {
        let items = ItemRepository(manager: manager)
        let source = try items.create(Item(type: .text, title: "Source", contentText: "Source body"))
        let fact = try repository.create(text: "Important fact", sourceItem: source)
        XCTAssertEqual(fact.sourceItemId, source.id)
        XCTAssertEqual(try items.fetch(id: fact.itemId)?.type, .fact)
    }

    func testFactCopyWithSourceFormat() {
        let fact = FactCard(text: "Fact", sourceItemId: "s1", itemId: "f1")
        XCTAssertEqual(repository.copyFormat(fact, sourceTitle: "Article"), "Fact — Article")
    }
}
