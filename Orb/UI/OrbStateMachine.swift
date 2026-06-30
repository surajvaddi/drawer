import SwiftUI

enum OrbVisualState: String, Equatable, Sendable {
    case idle
    case clipboardChanged
    case dragHover
    case saving
    case expanded
}

struct OrbStateMachine: Sendable {
    private(set) var state: OrbVisualState = .idle

    mutating func transition(to newState: OrbVisualState) throws {
        guard isValidTransition(from: state, to: newState) else {
            throw OrbError.invalidData("Invalid orb transition \(state) -> \(newState)")
        }
        state = newState
    }

    private func isValidTransition(from: OrbVisualState, to: OrbVisualState) -> Bool {
        if from == to { return true }
        switch (from, to) {
        case (.idle, .clipboardChanged), (.idle, .dragHover), (.idle, .expanded),
             (.clipboardChanged, .idle), (.clipboardChanged, .saving), (.clipboardChanged, .expanded),
             (.dragHover, .idle), (.dragHover, .saving),
             (.saving, .idle), (.saving, .expanded),
             (.expanded, .idle):
            return true
        default:
            return false
        }
    }
}
