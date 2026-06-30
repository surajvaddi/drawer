import XCTest
@testable import Orb

final class TextItemProcessorIntegrationTests: XCTestCase {
    func testSaveTextClipboardEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-text-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let saved = try TextItemProcessor(coordinator: StorageCoordinator(paths: paths, manager: manager))
            .process(text: "integration text")
        XCTAssertEqual(saved.type, .text)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
