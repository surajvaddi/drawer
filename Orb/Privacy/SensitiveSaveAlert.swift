import Foundation

enum SensitiveSaveChoice: Equatable, Sendable {
    case saveOnce
    case saveToPrivateDrawer
    case dontSave
}

struct SensitiveSaveAlert: Sendable {
    var findings: [SensitiveFinding]
}

struct SensitiveSaveController: Sendable {
    static let privateDrawerID = "private"

    func apply(choice: SensitiveSaveChoice, itemDrawerID: inout String?) -> Bool {
        switch choice {
        case .dontSave:
            return false
        case .saveOnce:
            return true
        case .saveToPrivateDrawer:
            itemDrawerID = Self.privateDrawerID
            return true
        }
    }
}
