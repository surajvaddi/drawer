import XCTest
@testable import Orb

final class CaptureEventLoggerIntegrationTests: XCTestCase {
    func testCaptureEventSurvivesRestart() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-cap-restart-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager1 = DatabaseManager(paths: paths)
        try manager1.open()
        try manager1.migrate(using: OrbMigrations.all)
        let mock = MockPasteboard()
        mock.setFixture(text: "persist event")
        let item = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager1),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        manager1.close()

        let manager2 = DatabaseManager(paths: paths)
        try manager2.open()
        let events = try CaptureEventRepository(manager: manager2).fetchAll()
        XCTAssertTrue(events.contains { $0.itemId == item.id })
        manager2.close()
        try? FileManager.default.removeItem(at: root)
    }
}
