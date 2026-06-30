import AppKit
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
        let windowTitle = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)?
            .compactMap { $0 as? [String: Any] }
            .first(where: { ($0[kCGWindowOwnerPID as String] as? Int32) == app.processIdentifier })?[kCGWindowName as String] as? String
        return SourceAppInfo(bundleID: bundleID, name: name, windowTitle: windowTitle)
    }
}

import CoreGraphics
