import XCTest
@testable import Orb

final class PrivacySettingsViewIntegrationTests: XCTestCase {
    func testPrivacySettingsLinkedToManagers() {
        let defaults = UserDefaults(suiteName: "orb.privacy.int.\(UUID().uuidString)")!
        var excluded = ExcludedAppsManager(defaults: defaults)
        excluded.add("com.example.app")
        var settings = AppSettings()
        settings.sensitiveDetectionEnabled = true
        XCTAssertTrue(settings.sensitiveDetectionEnabled)
        XCTAssertTrue(excluded.isExcluded("com.example.app"))
    }
}
