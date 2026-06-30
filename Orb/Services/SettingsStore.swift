import Foundation

struct OrbWindowPosition: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
}

struct AppSettings: Codable, Equatable, Sendable {
    var orbDiameter: Double = 48
    var orbOpacity: Double = 1
    var orbColorHex: String = "#FFFFFF"
    var edgeSnapEnabled: Bool = true
    var hideInFullscreen: Bool = false
    var clipboardPulseEnabled: Bool = true
    var defaultDrawerID: String = DefaultDataSeeder.inboxDrawerID
    var autoSaveClipboard: Bool = false
    var includeOCRInSearch: Bool = true
    var enterPastesInsteadOfCopy: Bool = false
    var sensitiveDetectionEnabled: Bool = true
    var importCopiesFiles: Bool = true
    var cacheSizeMB: Int = 512
}

final class SettingsStore: @unchecked Sendable {
    static let shared = SettingsStore()
    let defaults: UserDefaults
    private let positionKey = "orb.window.position"
    private let edgeSnapKey = "orb.window.edgeSnap"
    private let appSettingsKey = "orb.app_settings.json"

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

    func loadAppSettings() -> AppSettings {
        guard let data = defaults.data(forKey: appSettingsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    func saveAppSettings(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: appSettingsKey)
        }
    }

    func overlaySetting(_ repository: AppSettingsRepository, key: String, value: String) throws {
        try repository.set(key, value: value)
    }

    func overlayValue(_ repository: AppSettingsRepository, key: String, default defaultValue: String) throws -> String {
        try repository.get(key, default: defaultValue)
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
