import XCTest
@testable import Orb

final class ClipboardWatchSettingsIntegrationTests: XCTestCase {
    func testExcludedBundleIDSkipsDetection() {
        let settings = ClipboardWatchSettings(
            excludedBundleIDs: ["com.bank.app"],
            excludedAppsProvider: { "com.bank.app" }
        )
        let mock = MockPasteboard()
        let monitor = PasteboardMonitor(pasteboard: mock, settings: settings)
        mock.setString("secret", forType: .string)
        XCTAssertFalse(monitor.poll())
    }
}
