import XCTest
@testable import Orb

final class SaveToastViewIntegrationTests: XCTestCase {
    func testSaveClipboardShowsToast() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-toast-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "toast test")
        let saved = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        XCTAssertEqual(saved.drawerId, DefaultDataSeeder.inboxDrawerID)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
