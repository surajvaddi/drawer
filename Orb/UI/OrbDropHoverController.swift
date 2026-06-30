import Foundation

struct OrbDropHoverController: Sendable {
    private(set) var stateMachine = OrbStateMachine()

    mutating func dragEntered() throws {
        try stateMachine.transition(to: .dragHover)
    }

    mutating func dragExited() throws {
        try stateMachine.transition(to: .idle)
    }

    var label: String? {
        stateMachine.state == .dragHover ? "Drop to save" : nil
    }
}
