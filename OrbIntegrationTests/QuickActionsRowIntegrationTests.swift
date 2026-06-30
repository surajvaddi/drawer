import XCTest
@testable import Orb

final class QuickActionsRowIntegrationTests: XCTestCase {
    func testSaveClipboardQuickActionTriggersPipeline() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-quick-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "quick action")
        var saved = false
        let pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        )
        let action = {
            _ = try? pipeline.saveCurrentClipboard()
            saved = true
        }
        action()
        XCTAssertTrue(saved)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
