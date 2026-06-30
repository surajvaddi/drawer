import XCTest
@testable import Orb

final class AIProviderIntegrationTests: XCTestCase {
    func testProviderSwapDoesNotChangeQueueContract() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "content"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        XCTAssertEqual(job.kind, .title)
        XCTAssertEqual(try queue.pendingCount(), 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
