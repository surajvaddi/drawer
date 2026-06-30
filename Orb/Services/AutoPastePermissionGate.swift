import Foundation

struct AutoPastePermissionGate: Sendable {
    let permissions: PermissionService

    func canAutoPaste() -> Bool {
        permissions.status(for: .accessibility) == .granted
    }
}
