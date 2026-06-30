import XCTest
@testable import Orb

final class AIAnnotationViewsTests: XCTestCase {
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

    func testAcceptTitleUpdatesItem() throws {
        let items = ItemRepository(manager: manager)
        var item = try items.create(Item(type: .text, title: "Old Title", contentText: "content"))
        let suggested = "New Suggested Title"
        item.title = suggested
        _ = try items.update(item)
        let updated = try items.fetch(id: item.id)
        XCTAssertEqual(updated?.title, suggested)
    }

    func testDismissLeavesOriginal() throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Original", contentText: "content"))
        let annotations = AIAnnotationRepository(manager: manager)
        _ = try annotations.upsert(
            AIAnnotation(itemId: item.id, kind: .title, model: "mock", content: ["value": "Suggested"])
        )
        let unchanged = try items.fetch(id: item.id)
        XCTAssertEqual(unchanged?.title, "Original")
    }
}
