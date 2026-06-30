import XCTest
@testable import Orb

final class MarkdownExportServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(
            drawers: DrawerRepository(manager: manager),
            defaults: UserDefaults(suiteName: "orb.md-export.\(UUID().uuidString)")!
        ).seedIfNeeded()
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testMarkdownIncludesMetadata() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Meta Item", contentText: "content", drawerId: DefaultDataSeeder.inboxDrawerID))
        let md = try MarkdownExportService(items: items, drawers: drawers).export()
        XCTAssertTrue(md.contains("Meta Item"))
        XCTAssertTrue(md.contains("Type:"))
    }

    func testFactsRenderedAsList() throws {
        let items = ItemRepository(manager: manager)
        _ = try items.create(Item(type: .fact, title: "Fact one", contentText: "Fact one detail"))
        let md = try MarkdownExportService(items: items, drawers: DrawerRepository(manager: manager)).export()
        XCTAssertTrue(md.contains("Fact one"))
    }
}
