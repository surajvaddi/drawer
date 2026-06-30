import Foundation

struct ExcludedAppsManager: Sendable {
    private let defaults: UserDefaults
    private let key = "orb.excluded.bundleIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var bundleIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: key) ?? []) }
        set { defaults.set(Array(newValue), forKey: key) }
    }

    mutating func add(_ bundleID: String) {
        var ids = bundleIDs
        ids.insert(bundleID)
        bundleIDs = ids
    }

    mutating func remove(_ bundleID: String) {
        var ids = bundleIDs
        ids.remove(bundleID)
        bundleIDs = ids
    }

    func isExcluded(_ bundleID: String?) -> Bool {
        guard let bundleID else { return false }
        return bundleIDs.contains(bundleID)
    }
}
