import XCTest
@testable import Orb

final class AIWorkerIntegrationTests: XCTestCase {
    func testSavedItemGetsAIAnnotationsAfterWorker() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        var settings = AppSettings()
        settings.aiEnabled = true
        let items = ItemRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Note", contentText: "Quarterly revenue grew by twenty percent year over year"))
        let queue = AIJobQueue(manager: manager)
        _ = try queue.enqueue(itemId: item.id, kind: .summary)
        let worker = AIWorker(
            queue: queue,
            items: items,
            annotations: AIAnnotationRepository(manager: manager),
            provider: MockAIProvider(),
            privacyGate: AIPrivacyGate(settings: settings)
        )
        let processed = try await worker.drain()
        XCTAssertGreaterThan(processed, 0)
        let annotations = try AIAnnotationRepository(manager: manager).fetchAll(itemId: item.id)
        XCTAssertFalse(annotations.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
