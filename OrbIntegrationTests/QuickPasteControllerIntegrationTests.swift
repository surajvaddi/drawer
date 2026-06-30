import XCTest
@testable import Orb

final class QuickPasteControllerIntegrationTests: XCTestCase {
    func testQuickPasteCopyThenSystemPaste() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-qp-copy-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let saved = try items.create(Item(type: .text, title: "Paste", contentText: "Paste"))
        let pasteboard = MockPasteboard()
        try QuickPasteController(items: items, pasteboard: pasteboard).copy(item: saved)
        XCTAssertEqual(pasteboard.string(forType: .string), "Paste")
        manager.close()
    }
}
