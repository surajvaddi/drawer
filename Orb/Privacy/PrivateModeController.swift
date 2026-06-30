import Foundation

struct PrivateModeController: Sendable {
    private let defaults: UserDefaults
    private let key = "orb.private_mode"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }

    func blocksSave() -> Bool { isEnabled }
    func orbBadgeVisible() -> Bool { isEnabled }
}
