import XCTest
@testable import Orb

final class DefaultDataSeederIntegrationTests: XCTestCase {
    func testFreshInstallHasInboxDrawer() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("orb-seeder-int-\(UUID().uuidString)", isDirectory: true)
        let suiteName = "orb.seeder.int.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let seeder = DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: defaults)
        _ = try seeder.seedIfNeeded()
        let drawers = try DrawerRepository(manager: manager).fetchAll()
        XCTAssertTrue(drawers.contains { $0.name == DefaultDataSeeder.inboxDrawerName })
        manager.close()
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: root)
    }
}
