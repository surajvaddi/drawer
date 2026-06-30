import XCTest
@testable import Orb

final class DuplicateDetectorIntegrationTests: XCTestCase {
    func testDuplicateSaveShowsMergeDialog() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let text = "Duplicate content for merge flow integration test"
        let primary = try items.create(Item(type: .text, title: "Primary", contentText: text))
        let duplicate = try items.create(Item(type: .text, title: "Duplicate", contentText: text))
        let detector = DuplicateDetector(items: items, provider: MockAIProvider(), queue: AIJobQueue(manager: manager), threshold: 0.5)
        let candidates = try await detector.findDuplicates(for: primary)
        XCTAssertTrue(candidates.contains { $0.itemId == duplicate.id })
        let deletion = ItemDeletionService(
            items: items,
            blobs: BlobRepository(manager: manager),
            annotations: AIAnnotationRepository(manager: manager),
            blobStore: BlobStore(paths: paths)
        )
        let merged = try DuplicateMergeFlow(items: items, tags: tags, deletion: deletion).merge(primaryID: primary.id, duplicateID: duplicate.id)
        XCTAssertNil(try items.fetch(id: duplicate.id))
        XCTAssertNotNil(try items.fetch(id: merged.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
