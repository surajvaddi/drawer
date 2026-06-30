import XCTest
@testable import Orb

final class HotkeyServiceIntegrationTests: XCTestCase {
    func testSaveClipboardShortcutInvokesPipeline() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-hotkey-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "hotkey save")
        let pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        )
        let hotkeys = HotkeyService()
        hotkeys.register(.saveClipboard) {
            _ = try? pipeline.saveCurrentClipboard()
        }
        hotkeys.invoke(.saveClipboard)
        let items = try ItemRepository(manager: manager).listRecent()
        XCTAssertTrue(items.contains { $0.preview.contains("hotkey") || $0.contentText?.contains("hotkey") == true })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
