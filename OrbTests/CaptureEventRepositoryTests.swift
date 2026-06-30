import XCTest
@testable import Orb

final class CaptureEventRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var items: ItemRepository!
    private var events: CaptureEventRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-capture-repo-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        items = ItemRepository(manager: manager)
        events = CaptureEventRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testLogCaptureEventStoresMethod() throws {
        let item = try items.create(Item(type: .text, title: "Clip"))
        let event = CaptureEvent(itemId: item.id, method: .clipboardSave, sourceApp: "Safari")
        let saved = try events.log(event)
        XCTAssertEqual(saved.method, .clipboardSave)
        XCTAssertEqual(try events.fetchAll().count, 1)
    }

    func testFetchPendingEventsOrderedByDate() throws {
        let item = try items.create(Item(type: .text, title: "Clip"))
        let first = CaptureEvent(itemId: item.id, method: .dragDrop, createdAt: Date(timeIntervalSince1970: 100))
        let second = CaptureEvent(itemId: item.id, method: .screenshot, createdAt: Date(timeIntervalSince1970: 200))
        _ = try events.log(second)
        _ = try events.log(first)
        let pending = try events.fetchPending()
        XCTAssertEqual(pending.count, 2)
        XCTAssertEqual(pending.first?.method, .dragDrop)
    }
}
