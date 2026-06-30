import XCTest
@testable import Orb

final class ShortcutSettingsTests: XCTestCase {
    func testOverrideDefaultShortcut() throws {
        let defaults = UserDefaults(suiteName: "orb.shortcut.\(UUID().uuidString)")!
        let settings = ShortcutSettings(defaults: defaults)
        let custom = ShortcutBinding(keyCode: 1, modifiers: [.command])
        try settings.setBinding(custom, for: .saveClipboard)
        XCTAssertEqual(settings.binding(for: .saveClipboard), custom)
    }

    func testDetectShortcutConflicts() throws {
        let defaults = UserDefaults(suiteName: "orb.shortcut.\(UUID().uuidString)")!
        let settings = ShortcutSettings(defaults: defaults)
        let binding = ShortcutBinding(keyCode: 2, modifiers: [.command, .shift])
        try settings.setBinding(binding, for: .saveClipboard)
        XCTAssertEqual(try settings.conflicts(with: binding), .saveClipboard)
    }
}
