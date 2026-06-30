import XCTest
@testable import Orb

final class JSONImportServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testImportSkipsDuplicatesWhenConfigured() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let item = try items.create(Item(type: .text, title: "Dup", contentText: "x"))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        let result = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: true)
        XCTAssertEqual(result.items, 0)
        XCTAssertNotNil(try items.fetch(id: item.id))
    }

    func testImportPreservesDrawerHierarchy() throws {
        let items = ItemRepository(manager: manager)
        let drawers = DrawerRepository(manager: manager)
        let tags = TagRepository(manager: manager)
        let parent = try drawers.create(Drawer(name: "Parent", sortOrder: 0))
        let child = try drawers.create(Drawer(name: "Child", parentDrawerId: parent.id, sortOrder: 1))
        let data = try JSONExportService(items: items, drawers: drawers, tags: tags).export()
        try manager.exec("DELETE FROM drawers;")
        _ = try JSONImportService(items: items, drawers: drawers, tags: tags).importData(data, merge: false)
        XCTAssertNotNil(try drawers.fetch(id: parent.id))
        XCTAssertEqual(try drawers.fetch(id: child.id)?.parentDrawerId, parent.id)
    }
}
