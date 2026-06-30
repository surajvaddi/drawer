import XCTest
@testable import Orb

final class JSONExportServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(
            drawers: DrawerRepository(manager: manager),
            defaults: UserDefaults(suiteName: "orb.json-export.\(UUID().uuidString)")!
        ).seedIfNeeded()
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testExportIncludesAllEntities() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        _ = try items.create(Item(type: .text, title: "ExportMe", contentText: "body"))
        _ = try tags.create(name: "export-tag")
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(JSONExportPayload.self, from: data)
        XCTAssertFalse(payload.items.isEmpty)
        XCTAssertFalse(payload.tags.isEmpty)
    }

    func testExportValidJSON() throws {
        let service = JSONExportService(
            items: ItemRepository(manager: manager),
            drawers: DrawerRepository(manager: manager),
            tags: TagRepository(manager: manager)
        )
        let data = try service.export()
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }
}
