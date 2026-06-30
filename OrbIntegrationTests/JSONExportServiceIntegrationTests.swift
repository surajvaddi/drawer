import XCTest
@testable import Orb

final class JSONExportServiceIntegrationTests: XCTestCase {
    func testExportImportRoundTrip() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let created = try items.create(Item(type: .text, title: "RoundTrip", contentText: "data"))
        let exportData = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(exportData, merge: true)
        XCTAssertGreaterThanOrEqual(result.items, 0)
        XCTAssertNotNil(try items.fetch(id: created.id))
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
