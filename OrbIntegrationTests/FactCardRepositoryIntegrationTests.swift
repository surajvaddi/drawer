import XCTest
@testable import Orb

final class FactCardRepositoryIntegrationTests: XCTestCase {
    func testConvertTextSelectionToFactCard() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-fact-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let source = try items.create(Item(type: .text, title: "Article", contentText: "Long article"))
        let fact = try FactCardRepository(items: items).create(text: "Key insight", sourceItem: source)
        XCTAssertEqual(try items.fetch(id: fact.itemId)?.sourceItemId, source.id)
        manager.close()
    }
}
