import XCTest
@testable import Orb

final class DefaultDataSeederTests: XCTestCase {
    private var manager: DatabaseManager!
    private var drawers: DrawerRepository!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        suiteName = "orb.seeder.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-seeder-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        drawers = DrawerRepository(manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testSeederRunsOnlyOnce() throws {
        let seeder = DefaultDataSeeder(drawers: drawers, defaults: defaults)
        XCTAssertNotNil(try seeder.seedIfNeeded())
        XCTAssertNil(try seeder.seedIfNeeded())
        XCTAssertEqual(try drawers.fetchAll().count, 1)
    }

    func testInboxDrawerIsPinned() throws {
        let seeder = DefaultDataSeeder(drawers: drawers, defaults: defaults)
        let inbox = try seeder.seedIfNeeded()
        XCTAssertEqual(inbox?.name, DefaultDataSeeder.inboxDrawerName)
        XCTAssertEqual(inbox?.isPinned, true)
    }
}
