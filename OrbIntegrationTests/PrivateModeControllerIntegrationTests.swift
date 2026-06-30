import XCTest
@testable import Orb

final class PrivateModeControllerIntegrationTests: XCTestCase {
    func testPrivateModeEndToEnd() throws {
        let defaults = UserDefaults(suiteName: "orb.private.int.\(UUID().uuidString)")!
        let controller = PrivateModeController(defaults: defaults)
        controller.isEnabled = true
        let settings = ClipboardWatchSettings(isPrivateMode: controller.isEnabled)
        let mock = MockPasteboard()
        mock.setFixture(text: "blocked")
        let monitor = PasteboardMonitor(pasteboard: mock, settings: settings)
        mock.setString("changed", forType: .string)
        XCTAssertFalse(monitor.poll())
    }
}
