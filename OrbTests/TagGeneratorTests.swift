import XCTest
@testable import Orb

final class TagGeneratorTests: XCTestCase {
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

    func testTagsDedupedAndNormalized() async throws {
        let provider = MockAIProvider()
        let generator = TagGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            tags: TagRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = "engineering engineering platform platform backend backend services"
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Tags", contentText: text)
        )
        let tags = try await generator.generate(for: item)
        let names = tags.map(\.name)
        XCTAssertEqual(Set(names).count, names.count)
    }

    func testMaxTagsLimit() async throws {
        let provider = MockAIProvider()
        let generator = TagGenerator(
            provider: provider,
            annotations: AIAnnotationRepository(manager: manager),
            tags: TagRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let text = "alpha beta gamma delta epsilon zeta eta theta iota kappa lambda"
        let item = try ItemRepository(manager: manager).create(
            Item(type: .text, title: "Many", contentText: text)
        )
        let tags = try await generator.generate(for: item)
        XCTAssertLessThanOrEqual(tags.count, 5)
    }
}
