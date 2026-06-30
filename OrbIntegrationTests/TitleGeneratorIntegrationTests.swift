import XCTest
@testable import Orb

final class TitleGeneratorIntegrationTests: XCTestCase {
    func testLongTextItemGetsGeneratedTitle() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let longText = String(repeating: "Detailed quarterly report section. ", count: 20)
        let item = try items.create(Item(type: .text, title: "", contentText: longText))
        let generator = TitleGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        let title = try await generator.generate(for: item)
        XCTAssertFalse(title.isEmpty)
        let annotation = try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .title)
        XCTAssertNotNil(annotation)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
