import XCTest
@testable import Orb

final class ClipboardWatchSettingsTests: XCTestCase {
    func testPauseStopsChangeNotifications() {
        let settings = ClipboardWatchSettings(isPaused: true)
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock, settings: settings)
        mock.setString("paused", forType: .string)
        XCTAssertFalse(monitor.poll())
    }

    func testExcludedAppBlocksPulse() {
        let settings = ClipboardWatchSettings(
            excludedBundleIDs: ["com.example.app"],
            excludedAppsProvider: { "com.example.app" }
        )
        XCTAssertTrue(settings.shouldIgnoreCurrentApp())
    }
}
