import XCTest
@testable import Orb

final class DuplicateMergeFlowIntegrationTests: XCTestCase {
    func testDuplicateURLSaveShowsMergeDialog() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let url = "https://duplicate.example/page"
        let a = try items.create(Item(type: .url, title: "A", contentText: "same page content", sourceURL: url))
        let b = try items.create(Item(type: .url, title: "B", contentText: "same page content", sourceURL: url))
        let dupes = try await DuplicateDetector(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager), threshold: 0.5).findDuplicates(for: a)
        XCTAssertTrue(dupes.contains { $0.itemId == b.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
