import XCTest
@testable import Orb

final class ExcludedAppsManagerIntegrationTests: XCTestCase {
    func testExcludedAppClipboardNotDetected() {
        let defaults = UserDefaults(suiteName: "orb.excluded.int.\(UUID().uuidString)")!
        var manager = ExcludedAppsManager(defaults: defaults)
        manager.add("com.bank.app")
        let settings = ClipboardWatchSettings(
            excludedBundleIDs: manager.bundleIDs,
            excludedAppsProvider: { "com.bank.app" }
        )
        let mock = MockPasteboard()
        mock.setFixture(text: "should ignore")
        let monitor = PasteboardMonitor(pasteboard: mock, settings: settings)
        mock.setString("changed", forType: .string)
        XCTAssertFalse(monitor.poll())
    }
}
