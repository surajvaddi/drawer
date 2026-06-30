import Foundation

struct OrbWindowPosition: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
}

final class SettingsStore: @unchecked Sendable {
    static let shared = SettingsStore()
    private let defaults: UserDefaults
    private let positionKey = "orb.window.position"
    private let edgeSnapKey = "orb.window.edgeSnap"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var orbPosition: OrbWindowPosition? {
        get {
            guard let data = defaults.data(forKey: positionKey) else { return nil }
            return try? JSONDecoder().decode(OrbWindowPosition.self, from: data)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: positionKey)
                return
            }
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: positionKey)
            }
        }
    }

    var edgeSnapEnabled: Bool {
        get { defaults.object(forKey: edgeSnapKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: edgeSnapKey) }
    }
}

struct OrbDragController: Sendable {
    let settings: SettingsStore

    func persist(origin: NSPoint) {
        settings.orbPosition = OrbWindowPosition(x: origin.x, y: origin.y)
    }

    func restoredOrigin(defaultOrigin: NSPoint) -> NSPoint {
        guard let saved = settings.orbPosition else { return defaultOrigin }
        return NSPoint(x: saved.x, y: saved.y)
    }
}

import AppKit
