import XCTest
@testable import Orb

final class CaptureSettingsViewTests: XCTestCase {
    func testPauseClipboardWatcherSetting() {
        var settings = AppSettings()
        settings.clipboardPulseEnabled = false
        let watch = ClipboardWatchSettings(isPaused: !settings.clipboardPulseEnabled)
        XCTAssertTrue(watch.isPaused)
    }

    func testDefaultDrawerSelection() {
        var settings = AppSettings()
        settings.defaultDrawerID = "work"
        XCTAssertEqual(settings.defaultDrawerID, "work")
    }
}
