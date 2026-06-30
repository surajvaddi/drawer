import Foundation

struct ScreenshotPermissionGate: Sendable {
    let permissions: PermissionService

    func canCapture() -> Bool {
        permissions.status(for: .screenRecording) == .granted
    }

    func fallbackMessage() -> String {
        "Screen Recording permission is required to capture screenshots."
    }
}
