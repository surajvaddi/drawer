import XCTest
@testable import Orb

final class DrawerRepositoryIntegrationTests: XCTestCase {
    func testDrawerTreePersistsAndReloads() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-drawer-repo-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)

        let manager1 = DatabaseManager(paths: paths)
        try manager1.open()
        try manager1.migrate(using: OrbMigrations.all)
        let repo1 = DrawerRepository(manager: manager1)
        let parent = try repo1.create(Drawer(name: "Research", sortOrder: 0))
        _ = try repo1.create(Drawer(name: "Concrete", parentDrawerId: parent.id, sortOrder: 1))
        manager1.close()

        let manager2 = DatabaseManager(paths: paths)
        try manager2.open()
        let repo2 = DrawerRepository(manager: manager2)
        let drawers = try repo2.fetchTree()
        XCTAssertEqual(drawers.count, 2)
        XCTAssertEqual(drawers[1].path(in: drawers), "Research / Concrete")
        manager2.close()
        try? FileManager.default.removeItem(at: root)
    }
}
