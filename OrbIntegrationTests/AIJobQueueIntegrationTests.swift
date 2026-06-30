import XCTest
@testable import Orb

final class AIJobQueueIntegrationTests: XCTestCase {
    func testQueuePersistsAcrossRelaunch() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        var manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Persist", contentText: "data"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .summary)
        manager.close()
        manager = DatabaseManager(paths: paths)
        try manager.open()
        let queue2 = AIJobQueue(manager: manager)
        XCTAssertEqual(try queue2.pendingCount(), 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
