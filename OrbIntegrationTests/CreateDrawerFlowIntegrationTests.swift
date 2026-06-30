import XCTest
@testable import Orb

final class CreateDrawerFlowIntegrationTests: XCTestCase {
    func testNewDrawerAppearsInDrawerList() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-create-int-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let drawers = DrawerRepository(manager: manager)
        _ = try CreateDrawerFlow(drawers: drawers).create(CreateDrawerRequest(name: "Research", icon: "book", color: "#336699"))
        XCTAssertTrue(try drawers.fetchAll().contains { $0.name == "Research" })
        manager.close()
    }
}
