import XCTest
@testable import Orb

final class TitleGeneratorTests: XCTestCase {
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

    func testTitleFallsBackToFirstLine() async throws {
        let provider = MockAIProvider()
        let generator = TitleGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "", contentText: "First line title here\nSecond line ignored")
        )
        let title = try await generator.generate(for: item)
        XCTAssertFalse(title.isEmpty)
        XCTAssertTrue(title.contains("First") || title.contains("line"))
    }

    func testTitleMaxLengthEnforced() async throws {
        let provider = MockAIProvider()
        let generator = TitleGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let longText = (0..<30).map { "word\($0)" }.joined(separator: " ")
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "", contentText: longText)
        )
        let title = try await generator.generate(for: item)
        let wordCount = title.split(separator: " ").count
        XCTAssertLessThanOrEqual(wordCount, 6)
    }
}
