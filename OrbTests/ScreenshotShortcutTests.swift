import XCTest
@testable import Orb

final class ScreenshotShortcutTests: XCTestCase {
    func testScreenshotShortcutStartsOverlay() {
        let hotkeys = HotkeyService()
        var started = false
        let shortcut = ScreenshotShortcut(hotkeys: hotkeys, onStartCapture: { started = true })
        shortcut.register()
        hotkeys.invoke(.screenshot)
        XCTAssertTrue(started)
    }
}
