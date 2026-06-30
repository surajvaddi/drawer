import Foundation

struct ClipboardWatchSettings: Sendable {
    var isPaused: Bool
    var isPrivateMode: Bool
    var excludedBundleIDs: Set<String>
    var excludedAppsProvider: @Sendable () -> String?

    init(
        isPaused: Bool = false,
        isPrivateMode: Bool = false,
        excludedBundleIDs: Set<String> = [],
        excludedAppsProvider: @escaping @Sendable () -> String? = {
            NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        }
    ) {
        self.isPaused = isPaused
        self.isPrivateMode = isPrivateMode
        self.excludedBundleIDs = excludedBundleIDs
        self.excludedAppsProvider = excludedAppsProvider
    }

    func shouldIgnoreCurrentApp() -> Bool {
        guard let bundleID = excludedAppsProvider() else { return false }
        return excludedBundleIDs.contains(bundleID)
    }

    var shouldBlockCapture: Bool {
        isPaused || isPrivateMode
    }
}

import AppKit
