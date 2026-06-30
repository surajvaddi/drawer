import XCTest
@testable import Orb

final class SourceAppResolverIntegrationTests: XCTestCase {
    func testSavedItemIncludesSourceAppMetadata() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-source-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let mock = MockPasteboard()
        mock.setFixture(text: "with source")
        let pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock),
            sourceResolver: SourceAppResolver()
        )
        let item = try pipeline.saveCurrentClipboard()
        XCTAssertNotNil(item.sourceApp)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
