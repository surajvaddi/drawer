import XCTest
@testable import Orb

final class DrawerRepositoryTests: XCTestCase {
    private var manager: DatabaseManager!
    private var repository: DrawerRepository!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-drawer-repo-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        repository = DrawerRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
    }

    func testCreateNestedDrawer() throws {
        let parent = try repository.create(Drawer(name: "Jobs", sortOrder: 0))
        let child = try repository.create(Drawer(name: "Modal", parentDrawerId: parent.id, sortOrder: 1))
        let drawers = try repository.fetchAll()
        XCTAssertEqual(child.parentDrawerId, parent.id)
        XCTAssertEqual(drawers.count, 2)
    }

    func testReorderDrawersUpdatesSortOrder() throws {
        let a = try repository.create(Drawer(name: "A", sortOrder: 0))
        let b = try repository.create(Drawer(name: "B", sortOrder: 1))
        try repository.reorder(drawerIDsInOrder: [b.id, a.id])
        let drawers = try repository.fetchAll()
        XCTAssertEqual(drawers.first?.id, b.id)
        XCTAssertEqual(drawers.first?.sortOrder, 0)
    }
}
