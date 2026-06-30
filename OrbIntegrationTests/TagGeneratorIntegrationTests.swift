import XCTest
@testable import Orb

final class TagGeneratorIntegrationTests: XCTestCase {
    func testSuggestedTagsAppearInTagEditor() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Tagged", contentText: "swift programming language tutorial"))
        let generator = TagGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            tags: tags,
            queue: AIJobQueue(manager: manager)
        )
        _ = try await generator.generate(for: item)
        let linked = try tags.tags(for: item.id)
        XCTAssertFalse(linked.isEmpty)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
