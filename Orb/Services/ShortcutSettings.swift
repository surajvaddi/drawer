import AppKit
import Foundation

struct ShortcutBinding: Codable, Equatable, Sendable {
    var keyCode: UInt16
    var modifiersRaw: UInt

    var modifiers: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: modifiersRaw)
    }

    init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiersRaw = modifiers.rawValue
    }

    static func `default`(for shortcut: OrbShortcut) -> ShortcutBinding {
        ShortcutBinding(keyCode: shortcut.defaultKeyCode, modifiers: shortcut.defaultModifiers)
    }
}

struct ShortcutSettings: Sendable {
    private let defaults: UserDefaults
    private let prefix = "orb.shortcut."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func binding(for shortcut: OrbShortcut) -> ShortcutBinding {
        guard let data = defaults.data(forKey: prefix + shortcut.rawValue),
              let binding = try? JSONDecoder().decode(ShortcutBinding.self, from: data) else {
            return .default(for: shortcut)
        }
        return binding
    }

    func setBinding(_ binding: ShortcutBinding, for shortcut: OrbShortcut) throws {
        if try conflicts(with: binding, excluding: shortcut) != nil {
            throw OrbError.invalidData("Shortcut conflict detected")
        }
        let data = try JSONEncoder().encode(binding)
        defaults.set(data, forKey: prefix + shortcut.rawValue)
    }

    func conflicts(with binding: ShortcutBinding, excluding: OrbShortcut? = nil) throws -> OrbShortcut? {
        for shortcut in OrbShortcut.allCases where shortcut != excluding {
            if binding(for: shortcut) == binding { return shortcut }
        }
        return nil
    }
}
