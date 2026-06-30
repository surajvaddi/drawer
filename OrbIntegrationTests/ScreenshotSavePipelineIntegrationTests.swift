import XCTest
@testable import Orb

final class ScreenshotSavePipelineIntegrationTests: XCTestCase {
    func testScreenshotShortcutSavesToInbox() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-shot-inbox-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let saved = try ScreenshotSavePipeline(coordinator: StorageCoordinator(paths: paths, manager: manager))
            .save(imageData: TestFixtures.pngData())
        XCTAssertEqual(saved.type, .screenshot)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
