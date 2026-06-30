import AppKit
import Foundation

enum OrbShortcut: String, CaseIterable, Codable, Sendable {
    case saveClipboard
    case toggleDrawer
    case quickPaste
    case screenshot

    var defaultKeyCode: UInt16 {
        switch self {
        case .saveClipboard: return 8
        case .toggleDrawer: return 31
        case .quickPaste: return 9
        case .screenshot: return 19
        }
    }

    var defaultModifiers: NSEvent.ModifierFlags {
        [.command, .shift]
    }
}

final class HotkeyService: @unchecked Sendable {
    private var handlers: [OrbShortcut: () -> Void] = [:]
    private(set) var registered: Set<OrbShortcut> = []

    func register(_ shortcut: OrbShortcut, handler: @escaping () -> Void) {
        handlers[shortcut] = handler
        registered.insert(shortcut)
    }

    func unregisterAll() {
        handlers.removeAll()
        registered.removeAll()
    }

    func invoke(_ shortcut: OrbShortcut) {
        handlers[shortcut]?()
    }

    func registerDefaults(
        onSaveClipboard: @escaping () -> Void = {},
        onToggleDrawer: @escaping () -> Void = {},
        onQuickPaste: @escaping () -> Void = {},
        onScreenshot: @escaping () -> Void = {}
    ) {
        register(.saveClipboard, handler: onSaveClipboard)
        register(.toggleDrawer, handler: onToggleDrawer)
        register(.quickPaste, handler: onQuickPaste)
        register(.screenshot, handler: onScreenshot)
    }

    deinit {
        unregisterAll()
    }
}
