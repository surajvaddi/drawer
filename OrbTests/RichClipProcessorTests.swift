import XCTest
@testable import Orb

final class RichClipProcessorTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var processor: RichClipProcessor!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-rich-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        processor = RichClipProcessor(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testStoresHTMLAndPlainText() throws {
        let saved = try processor.process(plainText: "Hello", html: "<p>Hello</p>")
        XCTAssertEqual(saved.contentText, "Hello")
        XCTAssertEqual(saved.contentHTML, "<p>Hello</p>")
        XCTAssertEqual(saved.type, .richClip)
    }

    func testStripHTMLForPreview() {
        let preview = processor.stripHTMLForPreview("<p><strong>Title</strong> body</p>")
        XCTAssertEqual(preview, "Title body")
    }
}
