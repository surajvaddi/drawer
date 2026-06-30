import XCTest
@testable import Orb

final class RichClipProcessorIntegrationTests: XCTestCase {
    func testSaveRichTextClipboardEndToEnd() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-rich-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let saved = try RichClipProcessor(coordinator: StorageCoordinator(paths: paths, manager: manager))
            .process(plainText: "Hello", html: "<b>Hello</b>")
        XCTAssertEqual(saved.type, .richClip)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
