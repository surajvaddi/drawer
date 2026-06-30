import XCTest
@testable import Orb

final class NestedDrawerServiceIntegrationTests: XCTestCase {
    func testNestedDrawerTreePersists() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-nested-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        let service = NestedDrawerService(drawers: drawers)
        let parent = try drawers.create(Drawer(name: "Work"))
        let child = try drawers.create(Drawer(name: "Jobs"))
        try service.reparent(drawerID: child.id, toParent: parent.id)
        XCTAssertEqual(try drawers.fetch(id: child.id)?.parentDrawerId, parent.id)
        manager.close()
    }
}
