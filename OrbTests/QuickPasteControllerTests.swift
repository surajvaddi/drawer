import XCTest
@testable import Orb

final class QuickPasteControllerTests: XCTestCase {
    private var manager: DatabaseManager!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-qp-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws { manager.close() }

    func testEnterCopiesSelectedItem() throws {
        let items = ItemRepository(manager: manager)
        let saved = try items.create(Item(type: .text, title: "Hello", contentText: "Hello"))
        let pasteboard = MockPasteboard()
        let controller = QuickPasteController(items: items, pasteboard: pasteboard)
        try controller.copy(item: saved)
        XCTAssertEqual(pasteboard.string(forType: .string), "Hello")
    }

    func testUpdatesLastAccessedAt() throws {
        let items = ItemRepository(manager: manager)
        let saved = try items.create(Item(type: .text, title: "Hello", contentText: "Hello"))
        let controller = QuickPasteController(items: items, pasteboard: MockPasteboard())
        try controller.copy(item: saved)
        XCTAssertNotNil(try items.fetch(id: saved.id)?.lastAccessedAt)
    }
}
