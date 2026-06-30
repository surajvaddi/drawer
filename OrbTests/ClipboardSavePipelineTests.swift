import XCTest
@testable import Orb

final class ClipboardSavePipelineTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var pipeline: ClipboardSavePipeline!
    private var mock: MockPasteboard!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-clip-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        mock = MockPasteboard()
        pipeline = ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        )
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testSaveTextClipboardCreatesItem() throws {
        mock.setFixture(text: "saved snippet")
        let item = try pipeline.saveCurrentClipboard()
        XCTAssertEqual(item.type, .text)
        XCTAssertEqual(item.contentText, "saved snippet")
    }

    func testSaveImageClipboardCreatesBlob() throws {
        mock.setFixture(png: Data([0, 1, 2, 3, 4]))
        let item = try pipeline.saveCurrentClipboard()
        XCTAssertEqual(item.type, .screenshot)
        let blobs = try BlobRepository(manager: manager).list(itemId: item.id, kind: .original)
        XCTAssertEqual(blobs.count, 1)
    }
}
