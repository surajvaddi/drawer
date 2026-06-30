import XCTest
@testable import Orb

final class SummaryGeneratorTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testSummarySkippedForShortText() async throws {
        let provider = MockAIProvider()
        let generator = SummaryGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Short", contentText: "Hi")
        )
        let summary = try await generator.generate(for: item)
        XCTAssertEqual(summary, "Hi")
    }

    func testSummaryStoredAsAIAnnotation() async throws {
        let provider = MockAIProvider()
        let generator = SummaryGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = String(repeating: "Long content paragraph. ", count: 10)
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Doc", contentText: text)
        )
        _ = try await generator.generate(for: item)
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .summary)
        XCTAssertNotNil(annotation)
    }
}
