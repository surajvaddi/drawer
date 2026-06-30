import XCTest
@testable import Orb

final class ActivationFlowTests: XCTestCase {
    private func makeStack() throws -> (StoragePaths, DatabaseManager, ItemRepository, DrawerRepository) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-flow-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        return (paths, manager, ItemRepository(manager: manager), DrawerRepository(manager: manager))
    }

    func testFirstSaveFirstDrawerFirstRetrieveFlow() throws {
        let (paths, manager, items, drawers) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let mock = MockPasteboard()
        mock.setFixture(text: "first save content")
        let saved = try ClipboardSavePipeline(
            coordinator: StorageCoordinator(paths: paths, manager: manager),
            reader: PasteboardReader(pasteboard: mock)
        ).saveCurrentClipboard()
        XCTAssertEqual(saved.drawerId, DefaultDataSeeder.inboxDrawerID)
        let drawer = try drawers.fetch(id: DefaultDataSeeder.inboxDrawerID)
        XCTAssertNotNil(drawer)
        let found = try items.listRecent().first { $0.id == saved.id }
        XCTAssertNotNil(found)
    }

    func testQuickPasteReuseFlow() throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let item = try items.create(Item(type: .text, title: "Reuse", contentText: "reuse me"))
        let pasteboard = MockPasteboard()
        try QuickPasteController(items: items, pasteboard: pasteboard).copy(item: item)
        XCTAssertEqual(pasteboard.string(forType: .string), "reuse me")
    }

    func testScreenshotOCRSearchReuseFlow() throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let item = try items.create(Item(type: .screenshot, title: "Shot", contentText: "invoice-ocr-12345"))
        let results = try SearchRepository(manager: manager).search("invoice-ocr-12345")
        XCTAssertTrue(results.contains { $0.id == item.id })
    }

    func testJobDescriptionFactExtractionFlow() async throws {
        let (paths, manager, items, _) = try makeStack()
        defer { manager.close(); try? FileManager.default.removeItem(at: paths.root) }
        let jobText = "Senior iOS Engineer at Orb\nRequires Swift and SQLite experience\nRemote friendly with competitive pay"
        let item = try items.create(Item(type: .text, title: "Job Post", contentText: jobText))
        let facts = try await FactExtractor(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            factCards: FactCardRepository(items: items),
            queue: AIJobQueue(manager: manager)
        ).extract(from: item)
        XCTAssertFalse(facts.isEmpty)
    }
}
