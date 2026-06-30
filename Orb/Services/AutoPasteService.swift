import AppKit
import Foundation

struct AutoPasteService: Sendable {
    let defaults: UserDefaults
    private let enabledKey = "orb.auto_paste.enabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: enabledKey) }
        set { defaults.set(newValue, forKey: enabledKey) }
    }

    var isEnabledByDefault: Bool { false }

    func requiresAccessibilityPermission() -> Bool {
        !AXIsProcessTrusted()
    }

    func simulatePaste() throws {
        guard isEnabled else { return }
        guard !requiresAccessibilityPermission() else {
            throw OrbError.invalidData("Accessibility permission required for auto-paste")
        }
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}

import ApplicationServices
