import SwiftUI

enum OrbAnimationPolish {
    static let stateChange = Animation.easeInOut(duration: 0.22)
    static let pulse = Animation.spring(response: 0.35, dampingFraction: 0.65)
    static let saveSuccess = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let toastDismiss = Animation.easeOut(duration: 0.18)
    static let expand = Animation.interpolatingSpring(stiffness: 280, damping: 24)

    static func scale(for state: OrbVisualState, pulseScale: CGFloat) -> CGFloat {
        switch state {
        case .idle: return 1.0
        case .clipboardChanged: return pulseScale
        case .dragHover: return 1.08
        case .saving: return 0.94
        case .expanded: return 1.02
        }
    }

    static func shadowRadius(for state: OrbVisualState) -> CGFloat {
        switch state {
        case .dragHover, .expanded: return 12
        case .saving: return 6
        default: return 8
        }
    }

    static func iconOpacity(for state: OrbVisualState) -> Double {
        state == .saving ? 1.0 : 0.85
    }
}
