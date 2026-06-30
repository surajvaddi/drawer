import XCTest
@testable import Orb

final class LinkItemProcessorIntegrationTests: XCTestCase {
    func testSaveLinkClipboardEndToEnd() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-link-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let saved = try await LinkItemProcessor(coordinator: coordinator, metadataFetcher: MockLinkMetadataFetcher(title: "Example"))
            .process(urlString: "https://example.com")
        XCTAssertEqual(saved.type, .url)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
