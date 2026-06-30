import XCTest
@testable import Orb

final class AIWorkerTests: XCTestCase {
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

    func testWorkerWritesTitleAnnotation() async throws {
        var settings = AppSettings()
        settings.aiEnabled = true
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "", contentText: "Important meeting notes about project alpha"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .title)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        _ = try await worker.processNext()
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .title)
        XCTAssertNotNil(annotation)
    }

    func testWorkerMarksFailedOnError() async throws {
        var settings = AppSettings()
        settings.aiEnabled = false
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "T", contentText: "body"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .title)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        _ = try await worker.processNext()
        XCTAssertEqual(try queue.pendingCount(), 0)
    }
}
