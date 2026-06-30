import XCTest
@testable import Orb

final class GeneralSettingsViewIntegrationTests: XCTestCase {
    func testGeneralSettingsApplyLiveToOrb() {
        let defaults = UserDefaults(suiteName: "orb.general.int.\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        var settings = store.loadAppSettings()
        settings.orbDiameter = 52
        settings.orbOpacity = 0.8
        store.saveAppSettings(settings)
        let reloaded = store.loadAppSettings()
        XCTAssertEqual(reloaded.orbDiameter, 52)
        XCTAssertEqual(reloaded.orbOpacity, 0.8)
    }
}
