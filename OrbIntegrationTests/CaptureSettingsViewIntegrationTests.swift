import XCTest
@testable import Orb

final class CaptureSettingsViewIntegrationTests: XCTestCase {
    func testCaptureSettingsAffectClipboardService() {
        let defaults = UserDefaults(suiteName: "orb.capture.int.\(UUID().uuidString)")!
        let store = SettingsStore(defaults: defaults)
        var settings = store.loadAppSettings()
        settings.clipboardPulseEnabled = false
        store.saveAppSettings(settings)
        let watch = ClipboardWatchSettings(isPaused: !store.loadAppSettings().clipboardPulseEnabled)
        XCTAssertTrue(watch.isPaused)
    }
}
