import XCTest
@testable import Orb

final class CaptureEventLoggerTests: XCTestCase {
    func testClipboardSaveLogsCaptureEvent() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-cap-log-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "event test")
        let pipeline = ClipboardSavePipeline(coordinator: StorageCoordinator(paths: paths, manager: manager), reader: PasteboardReader(pasteboard: mock))
        let item = try pipeline.saveCurrentClipboard()
        let events = try CaptureEventRepository(manager: manager).fetchAll()
        XCTAssertTrue(events.contains { $0.itemId == item.id && $0.method == .clipboardSave })
        manager.close()
    }

    func testDragDropLogsCaptureEvent() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drag-log-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let pipeline = ClipboardSavePipeline(coordinator: StorageCoordinator(paths: paths, manager: manager))
        let item = try pipeline.saveDragDrop(
            payload: CapturePayload(type: .text, title: "Dropped", preview: "dropped", contentText: "dropped", method: .dragDrop)
        )
        let events = try CaptureEventRepository(manager: manager).fetchAll()
        XCTAssertTrue(events.contains { $0.itemId == item.id && $0.method == .dragDrop })
        manager.close()
    }
}
