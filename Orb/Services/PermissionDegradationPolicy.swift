import Foundation

struct FeatureAvailability: Equatable, Sendable {
    var clipboardSave: Bool
    var globalHotkeys: Bool
    var screenshotCapture: Bool
    var autoPaste: Bool
    var fileImport: Bool
    var search: Bool
}

struct PermissionDegradationPolicy: Sendable {
    let permissions: PermissionService

    func availability() -> FeatureAvailability {
        let statuses = permissions.allStatuses()
        return FeatureAvailability(
            clipboardSave: statuses[.clipboard] == .granted,
            globalHotkeys: statuses[.accessibility] == .granted,
            screenshotCapture: statuses[.screenRecording] == .granted,
            autoPaste: statuses[.accessibility] == .granted,
            fileImport: true,
            search: true
        )
    }

    func appUsable() -> Bool {
        let features = availability()
        return features.clipboardSave || features.fileImport || features.search
    }
}
