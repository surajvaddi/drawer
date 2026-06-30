import XCTest
@testable import Orb

final class CreateDrawerFlowTests: XCTestCase {
    private var manager: DatabaseManager!
    private var flow: CreateDrawerFlow!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-create-drawer-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        flow = CreateDrawerFlow(drawers: DrawerRepository(manager: manager))
    }

    override func tearDownWithError() throws { manager.close() }

    func testCreateDrawerValidatesName() {
        XCTAssertThrowsError(try flow.validate(name: "   "))
    }

    func testCreateDrawerAssignsSortOrder() throws {
        _ = try flow.create(CreateDrawerRequest(name: "A", icon: "folder", color: "#FF0000"))
        let second = try flow.create(CreateDrawerRequest(name: "B", icon: "folder", color: "#00FF00"))
        XCTAssertGreaterThan(second.sortOrder, 0)
    }
}
