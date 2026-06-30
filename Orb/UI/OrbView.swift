import SwiftUI

struct OrbView: View {
    let diameter: CGFloat
    let state: OrbVisualState
    let pulseScale: CGFloat

    init(diameter: CGFloat = 48, state: OrbVisualState = .idle, pulseScale: CGFloat = 1) {
        self.diameter = diameter
        self.state = state
        self.pulseScale = pulseScale
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                .frame(width: diameter, height: diameter)
                .scaleEffect(pulseScale)
            Image(systemName: iconName)
                .font(.system(size: diameter * 0.38, weight: .semibold))
                .foregroundStyle(.primary.opacity(0.85))
        }
        .overlay(alignment: .bottom) {
            if state == .dragHover {
                Text("Drop to save")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
                    .offset(y: diameter * 0.75)
            }
        }
        .animation(.easeOut(duration: 0.2), value: state)
    }

    private var iconName: String {
        switch state {
        case .idle, .clipboardChanged: return "circle.fill"
        case .dragHover: return "arrow.down.circle.fill"
        case .saving: return "checkmark.circle.fill"
        case .expanded: return "rectangle.expand.vertical"
        }
    }
}

#Preview {
    OrbView()
        .padding()
        .background(Color.gray.opacity(0.2))
}
