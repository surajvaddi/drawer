import XCTest
@testable import Orb

final class JSONImportServiceIntegrationTests: XCTestCase {
    func testImportJSONRestoresLibrary() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "Lib", contentText: "library"))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        try manager.exec("DELETE FROM items;")
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: false)
        XCTAssertGreaterThan(result.items, 0)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
