import ApplicationServices
import AppKit
import Foundation

enum PermissionKind: String, CaseIterable, Sendable {
    case clipboard
    case accessibility
    case screenRecording
    case files
}

enum PermissionStatus: String, Equatable, Sendable {
    case granted
    case denied
    case notDetermined
    case restricted
}

struct PermissionService: Sendable {
    func status(for kind: PermissionKind) -> PermissionStatus {
        switch kind {
        case .clipboard:
            return .granted
        case .accessibility:
            return AXIsProcessTrusted() ? .granted : .denied
        case .screenRecording:
            return CGPreflightScreenCaptureAccess() ? .granted : .denied
        case .files:
            return .notDetermined
        }
    }

    func allStatuses() -> [PermissionKind: PermissionStatus] {
        Dictionary(uniqueKeysWithValues: PermissionKind.allCases.map { ($0, status(for: $0)) })
    }
}
