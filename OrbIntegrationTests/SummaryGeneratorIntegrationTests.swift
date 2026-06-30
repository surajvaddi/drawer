import XCTest
@testable import Orb

final class SummaryGeneratorIntegrationTests: XCTestCase {
    func testPDFItemGetsSummaryAfterProcessing() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let pdfText = String(repeating: "PDF extracted content about revenue and growth metrics. ", count: 5)
        let item = try items.create(Item(type: .pdf, title: "Report", contentText: pdfText))
        let generator = SummaryGenerator(
            provider: MockAIProvider(),
            annotations: AIAnnotationRepository(manager: manager),
            queue: AIJobQueue(manager: manager)
        )
        _ = try await generator.generate(for: item)
        XCTAssertNotNil(try AIAnnotationRepository(manager: manager).fetch(itemId: item.id, kind: .summary))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
