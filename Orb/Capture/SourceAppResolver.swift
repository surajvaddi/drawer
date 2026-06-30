import AppKit
import CoreGraphics
import Foundation

struct SourceAppInfo: Equatable, Sendable {
    var bundleID: String?
    var name: String?
    var windowTitle: String?
}

struct SourceAppResolver: Sendable {
    func resolve() -> SourceAppInfo {
        guard let app = NSWorkspace.shared.frontmostApplication else {
            return SourceAppInfo()
        }
        let bundleID = app.bundleIdentifier
        let name = app.localizedName
        let windowTitle = frontWindowTitle(for: app.processIdentifier)
        return SourceAppInfo(bundleID: bundleID, name: name, windowTitle: windowTitle)
    }

    private func frontWindowTitle(for pid: pid_t) -> String? {
        guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        return windows.first(where: { ($0[kCGWindowOwnerPID as String] as? Int32) == pid })?[kCGWindowName as String] as? String
    }
}
