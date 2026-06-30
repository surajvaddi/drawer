import XCTest
@testable import Orb

final class NestedDrawerServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var drawers: DrawerRepository!
    private var service: NestedDrawerService!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-nested-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        drawers = DrawerRepository(manager: manager)
        service = NestedDrawerService(drawers: drawers)
    }

    override func tearDownWithError() throws { manager.close() }

    func testReparentDrawer() throws {
        let parent = try drawers.create(Drawer(name: "Parent"))
        let child = try drawers.create(Drawer(name: "Child"))
        try service.reparent(drawerID: child.id, toParent: parent.id)
        XCTAssertEqual(try drawers.fetch(id: child.id)?.parentDrawerId, parent.id)
    }

    func testCycleReparentRejected() throws {
        let a = try drawers.create(Drawer(name: "A"))
        let b = try drawers.create(Drawer(name: "B", parentDrawerId: a.id))
        XCTAssertThrowsError(try service.reparent(drawerID: a.id, toParent: b.id))
    }
}
