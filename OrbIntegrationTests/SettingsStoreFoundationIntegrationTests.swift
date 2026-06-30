import XCTest
@testable import Orb

final class SettingsStoreFoundationIntegrationTests: XCTestCase {
    func testSettingsStoreBacksUISettings() throws {
        let defaults = UserDefaults(suiteName: "orb.settings.int.\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        var settings = store.loadAppSettings()
        settings.orbDiameter = 64
        store.saveAppSettings(settings)
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-settings-overlay-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let repo = AppSettingsRepository(manager: manager)
        try store.overlaySetting(repo, key: "orbDiameter", value: "64")
        XCTAssertEqual(try store.overlayValue(repo, key: "orbDiameter", default: "48"), "64")
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
