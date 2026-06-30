import XCTest
@testable import Orb

final class OrbDropTargetIntegrationTests: XCTestCase {
    func testDropTextOnOrbSavesItem() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drop-text-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try await TextDropPipeline(coordinator: coordinator).importText("dropped text")
        XCTAssertEqual(saved.type, .text)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
