import XCTest
@testable import Orb

final class TextItemProcessorTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var processor: TextItemProcessor!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-text-proc-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        processor = TextItemProcessor(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testTitleFromFirstLine() throws {
        let saved = try processor.process(text: "Hello world\nsecond line")
        XCTAssertEqual(saved.title, "Hello world")
    }

    func testLongTextGetsPreviewOnly() throws {
        let long = String(repeating: "a", count: 400)
        let saved = try processor.process(text: long)
        XCTAssertLessThanOrEqual(saved.preview.count, Item.previewLimit + 1)
        XCTAssertEqual(saved.contentText?.count, 400)
    }
}
