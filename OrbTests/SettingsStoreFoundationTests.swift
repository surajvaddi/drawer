import XCTest
@testable import Orb

final class SettingsStoreFoundationTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        suiteName = "orb.settings.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testSettingsDefaultsApplied() {
        let store = SettingsStore(defaults: defaults)
        let settings = store.loadAppSettings()
        XCTAssertEqual(settings.orbDiameter, 48)
        XCTAssertEqual(settings.defaultDrawerID, DefaultDataSeeder.inboxDrawerID)
    }

    func testSettingsPersistAcrossLaunch() {
        let store = SettingsStore(defaults: defaults)
        var settings = store.loadAppSettings()
        settings.orbDiameter = 60
        store.saveAppSettings(settings)
        let reloaded = SettingsStore(defaults: defaults).loadAppSettings()
        XCTAssertEqual(reloaded.orbDiameter, 60)
    }
}
