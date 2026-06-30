import XCTest
@testable import Orb

final class LinkItemProcessorTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var coordinator: StorageCoordinator!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-link-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        coordinator = StorageCoordinator(paths: paths, manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testProcessorSetsTitleFromMetadata() async throws {
        let processor = LinkItemProcessor(coordinator: coordinator, metadataFetcher: MockLinkMetadataFetcher(title: "Example Site"))
        let saved = try await processor.process(urlString: "https://example.com/page")
        XCTAssertEqual(saved.title, "Example Site")
        XCTAssertEqual(saved.type, .url)
    }

    func testProcessorFallbackTitleUsesDomain() async throws {
        let processor = LinkItemProcessor(coordinator: coordinator, metadataFetcher: MockLinkMetadataFetcher(title: nil))
        let saved = try await processor.process(urlString: "https://news.ycombinator.com")
        XCTAssertEqual(saved.title, "news.ycombinator.com")
    }
}
