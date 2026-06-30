import XCTest
@testable import Orb

final class ClipboardSavePipelineIntegrationTests: XCTestCase {
    func testSaveClipboardAppearsInInbox() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-clip-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "inbox item")
        let pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        )
        let saved = try pipeline.saveCurrentClipboard()
        let items = try ItemRepository(manager: manager).listRecent()
        XCTAssertTrue(items.contains { $0.id == saved.id })
        XCTAssertEqual(saved.drawerId, DefaultDataSeeder.inboxDrawerID)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
