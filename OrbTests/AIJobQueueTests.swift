import XCTest
@testable import Orb

final class AIJobQueueTests: XCTestCase {
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

    func testEnqueueSetsPendingStatus() throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        XCTAssertEqual(job.status, .pending)
        XCTAssertEqual(try queue.pendingCount(), 1)
    }

    func testRetryFailedJob() throws {
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        let job = try queue.enqueue(itemId: item.id, kind: .title)
        _ = try queue.dequeue()
        try queue.markFailed(id: job.id, error: "test error")
        let retried = try queue.retryFailed()
        XCTAssertGreaterThan(retried, 0)
        XCTAssertEqual(try queue.pendingCount(), 1)
    }
}
