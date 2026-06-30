import XCTest
@testable import Orb

final class ShortcutSettingsIntegrationTests: XCTestCase {
    func testCustomShortcutTriggersAction() throws {
        let defaults = UserDefaults(suiteName: "orb.shortcut.int.\(UUID().uuidString)")!
        let settings = ShortcutSettings(defaults: defaults)
        let binding = ShortcutBinding(keyCode: 10, modifiers: [.command, .option])
        try settings.setBinding(binding, for: .quickPaste)
        let hotkeys = HotkeyService()
        var triggered = false
        hotkeys.register(.quickPaste) { triggered = true }
        XCTAssertEqual(settings.binding(for: .quickPaste), binding)
        hotkeys.invoke(.quickPaste)
        XCTAssertTrue(triggered)
    }
}
