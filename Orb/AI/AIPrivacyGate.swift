import Foundation

enum AIPrivacyDecision: Equatable, Sendable {
    case allowed
    case blocked(reason: String)
    case requiresConfirmation(reason: String)
}

struct AIPrivacyGate: Sendable {
    let settings: AppSettings

    func evaluate(operation: String, usesCloud: Bool) -> AIPrivacyDecision {
        guard settings.aiEnabled else {
            return .blocked(reason: "AI features are disabled")
        }
        if settings.aiLocalOnly && usesCloud {
            return .blocked(reason: "Cloud AI is disabled; local-only mode is on")
        }
        if usesCloud && settings.aiAskBeforeCloud {
            return .requiresConfirmation(reason: "\(operation) will send content to a cloud AI provider")
        }
        return .allowed
    }

    func canRunLocally(operation: String) -> AIPrivacyDecision {
        evaluate(operation: operation, usesCloud: false)
    }

    func canRunWithCloud(operation: String) -> AIPrivacyDecision {
        evaluate(operation: operation, usesCloud: true)
    }
}
