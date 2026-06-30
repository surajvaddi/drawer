import XCTest
@testable import Orb

final class MarkdownExportServiceIntegrationTests: XCTestCase {
    func testExportMarkdownMatchesFixture() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Fixture Item", contentText: "fixture body"))
        let md = try MarkdownExportService(items: items, drawers: drawers).export()
        XCTAssertTrue(md.hasPrefix("# Orb Export"))
        XCTAssertTrue(md.contains("Fixture Item"))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
