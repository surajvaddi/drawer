import XCTest
@testable import Orb

final class DuplicateDetectorTests: XCTestCase {
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

    func testDetectDuplicateURL() async throws {
        let items = ItemRepository(manager: manager)
        let url = "https://example.com/article"
        let a = try items.create(Item(type: .url, title: "A", contentText: "same article content here", sourceURL: url))
        let b = try items.create(Item(type: .url, title: "B", contentText: "same article content here", sourceURL: url))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.5
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains { $0.itemId == b.id })
    }

    func testDetectDuplicateTextHash() async throws {
        let items = ItemRepository(manager: manager)
        let text = "Identical clipboard text for duplicate detection testing"
        let a = try items.create(Item(type: .text, title: "A", contentText: text))
        let b = try items.create(Item(type: .text, title: "B", contentText: text))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.9
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains { $0.itemId == b.id })
    }

    func testDetectDuplicateFileChecksum() async throws {
        let items = ItemRepository(manager: manager)
        let checksum = "abc123checksum"
        let a = try items.create(Item(type: .file, title: "FileA", contentText: "file content \(checksum)"))
        let b = try items.create(Item(type: .file, title: "FileB", contentText: "file content \(checksum)"))
        let detector = DuplicateDetector(
            items: items,
            provider: MockAIProvider(),
            queue: AIJobQueue(manager: manager),
            threshold: 0.85
        )
        let dupes = try await detector.findDuplicates(for: a)
        XCTAssertTrue(dupes.contains { $0.itemId == b.id })
    }
}
