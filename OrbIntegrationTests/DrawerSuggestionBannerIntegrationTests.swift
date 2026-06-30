import XCTest
@testable import Orb

final class DrawerSuggestionBannerIntegrationTests: XCTestCase {
    func testSuggestionShownAfterLinkSave() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-suggest-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let rules = DrawerRuleRepository(manager: manager)
        let jobs = try drawers.create(Drawer(name: "Jobs"))
        _ = try rules.create(DrawerRule(drawerId: jobs.id, name: "Greenhouse", condition: ["url_contains": "greenhouse"], priority: 5))
        let coordinator = StorageCoordinator(paths: StoragePaths(root: root), manager: manager)
        let saved = try await LinkItemProcessor(coordinator: coordinator, metadataFetcher: MockLinkMetadataFetcher(title: "Role"))
            .process(urlString: "https://boards.greenhouse.io/acme")
        let suggestion = try DrawerRuleEvaluator(rules: rules, drawers: drawers).suggest(for: saved)
        XCTAssertNotNil(suggestion)
        manager.close()
    }
}
