import XCTest
@testable import Orb

final class DrawerRuleEvaluatorTests: XCTestCase {
    private var manager: DatabaseManager!
    private var evaluator: DrawerRuleEvaluator!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-rules-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let rules = DrawerRuleRepository(manager: manager)
        evaluator = DrawerRuleEvaluator(rules: rules, drawers: drawers)
    }

    override func tearDownWithError() throws { manager.close() }

    func testURLContainsRuleMatches() {
        let rule = DrawerRule(drawerId: "d1", name: "Jobs", condition: ["url_contains": "greenhouse"], priority: 1)
        let item = Item(type: .url, title: "Role", sourceURL: "https://boards.greenhouse.io/acme")
        XCTAssertTrue(evaluator.ruleMatches(rule: rule, item: item))
    }

    func testSourceAppRuleMatches() {
        let rule = DrawerRule(drawerId: "d1", name: "Safari", condition: ["source_app": "safari"], priority: 1)
        let item = Item(type: .text, title: "x", sourceApp: "Safari")
        XCTAssertTrue(evaluator.ruleMatches(rule: rule, item: item))
    }

    func testHighestPriorityWins() throws {
        let drawers = DrawerRepository(manager: manager)
        let rules = DrawerRuleRepository(manager: manager)
        let jobs = try drawers.create(Drawer(name: "Jobs"))
        let other = try drawers.create(Drawer(name: "Other"))
        _ = try rules.create(DrawerRule(drawerId: other.id, name: "Low", condition: ["url_contains": "greenhouse"], priority: 1))
        _ = try rules.create(DrawerRule(drawerId: jobs.id, name: "High", condition: ["url_contains": "greenhouse"], priority: 10))
        let item = Item(type: .url, title: "Role", sourceURL: "https://boards.greenhouse.io/acme")
        let suggestion = try DrawerRuleEvaluator(rules: rules, drawers: drawers).suggest(for: item)
        XCTAssertEqual(suggestion?.drawerID, jobs.id)
    }
}
