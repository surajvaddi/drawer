import Foundation
import ServiceManagement

struct LaunchAtLoginService: Sendable {
    private let defaultsKey = "orb.launch_at_login"

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: defaultsKey) }
        set { setEnabled(newValue) }
    }

    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: defaultsKey)
        if #available(macOS 13.0, *) {
            if enabled {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    func syncWithStoredPreference() {
        if #available(macOS 13.0, *) {
            let stored = UserDefaults.standard.bool(forKey: defaultsKey)
            if stored {
                try? SMAppService.mainApp.register()
            }
        }
    }
}
