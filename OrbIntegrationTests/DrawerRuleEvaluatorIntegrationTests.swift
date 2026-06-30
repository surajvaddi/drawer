import XCTest
@testable import Orb

final class DrawerRuleEvaluatorIntegrationTests: XCTestCase {
    func testGreenhouseURLSuggestsJobsDrawer() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-rule-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let rules = DrawerRuleRepository(manager: manager)
        let jobs = try drawers.create(Drawer(name: "Jobs"))
        _ = try rules.create(DrawerRule(drawerId: jobs.id, name: "Greenhouse", condition: ["url_contains": "greenhouse"], priority: 5))
        let item = Item(type: .url, title: "Role", sourceURL: "https://boards.greenhouse.io/acme")
        let suggestion = try DrawerRuleEvaluator(rules: rules, drawers: drawers).suggest(for: item)
        XCTAssertEqual(suggestion?.drawerID, jobs.id)
        manager.close()
    }
}
