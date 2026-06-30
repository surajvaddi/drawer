import XCTest
@testable import Orb

final class CaptureEventRepositoryIntegrationTests: XCTestCase {
    func testCaptureEventLinkedToSavedItem() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-capture-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let events = CaptureEventRepository(manager: manager)
        let item = try items.create(Item(type: .url, title: "Link", sourceURL: "https://example.com"))
        let event = try events.log(
            CaptureEvent(itemId: item.id, method: .clipboardSave, pasteboardTypes: ["public.url"])
        )
        XCTAssertEqual(event.itemId, item.id)
        XCTAssertEqual(try events.fetchAll().first?.itemId, item.id)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
