import XCTest
@testable import Orb

final class InboxListViewIntegrationTests: XCTestCase {
    func testSavedItemAppearsInInboxList() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-inbox-ui-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "drawer inbox")
        let saved = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        let model = DrawerViewModel(items: try ItemRepository(manager: manager).listRecent())
        XCTAssertTrue(model.inboxItems.contains { $0.id == saved.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
