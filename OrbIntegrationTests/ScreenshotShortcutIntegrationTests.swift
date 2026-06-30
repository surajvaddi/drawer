import XCTest
@testable import Orb

final class ScreenshotShortcutIntegrationTests: XCTestCase {
    func testScreenshotShortcutEndToEnd() {
        let hotkeys = HotkeyService()
        var started = false
        ScreenshotShortcut(hotkeys: hotkeys, onStartCapture: { started = true }).register()
        hotkeys.invoke(.screenshot)
        XCTAssertTrue(started)
    }
}
