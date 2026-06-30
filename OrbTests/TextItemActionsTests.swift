import XCTest
@testable import Orb

final class TextItemActionsTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var repository: ItemRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-text-actions-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = ItemRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testCopyWritesTextToPasteboard() throws {
        let pasteboard = MockPasteboard()
        let actions = TextItemActions(pasteboard: pasteboard, repository: repository)
        let item = Item(type: .text, title: "T", preview: "preview", contentText: "body")
        actions.copyPlainText(item)
        XCTAssertEqual(pasteboard.string(forType: .string), "body")
    }

    func testEditUpdatesContentText() throws {
        let saved = try repository.create(Item(type: .text, title: "Line one", contentText: "Line one"))
        let actions = TextItemActions(pasteboard: MockPasteboard(), repository: repository)
        let updated = try actions.editContent(saved, newText: "Updated body")
        XCTAssertEqual(updated.contentText, "Updated body")
    }
}
