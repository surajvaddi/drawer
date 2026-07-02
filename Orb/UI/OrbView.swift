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
            orbBody
                .frame(width: diameter, height: diameter)
                .scaleEffect(pulseScale)

            if let iconName {
                Image(systemName: iconName)
                    .font(.system(size: diameter * 0.34, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .shadow(color: .black.opacity(0.18), radius: 2, y: 1)
            }
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

    private var orbBody: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: palette,
                    center: UnitPoint(x: 0.34, y: 0.26),
                    startRadius: diameter * 0.04,
                    endRadius: diameter * 0.72
                )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(.white.opacity(0.32))
                    .frame(width: diameter * 0.28, height: diameter * 0.28)
                    .blur(radius: diameter * 0.05)
                    .offset(x: diameter * 0.18, y: diameter * 0.15)
            }
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.22), lineWidth: max(1, diameter * 0.018))
            }
            .shadow(color: shadowColor.opacity(0.28), radius: diameter * 0.14, y: diameter * 0.06)
    }

    private var palette: [Color] {
        switch state {
        case .idle:
            return [
                Color(red: 0.98, green: 1.00, blue: 1.00),
                Color(red: 0.42, green: 0.82, blue: 0.92),
                Color(red: 0.18, green: 0.42, blue: 0.62)
            ]
        case .clipboardChanged:
            return [
                Color(red: 1.00, green: 0.98, blue: 0.78),
                Color(red: 0.42, green: 0.84, blue: 0.68),
                Color(red: 0.16, green: 0.48, blue: 0.44)
            ]
        case .dragHover:
            return [
                Color(red: 1.00, green: 0.96, blue: 0.76),
                Color(red: 0.92, green: 0.52, blue: 0.28),
                Color(red: 0.50, green: 0.20, blue: 0.16)
            ]
        case .saving:
            return [
                Color(red: 0.90, green: 1.00, blue: 0.86),
                Color(red: 0.30, green: 0.78, blue: 0.44),
                Color(red: 0.10, green: 0.38, blue: 0.24)
            ]
        case .expanded:
            return [
                Color(red: 0.96, green: 0.96, blue: 1.00),
                Color(red: 0.50, green: 0.62, blue: 0.92),
                Color(red: 0.24, green: 0.30, blue: 0.58)
            ]
        }
    }

    private var shadowColor: Color {
        switch state {
        case .idle: return Color(red: 0.10, green: 0.36, blue: 0.50)
        case .clipboardChanged, .saving: return Color(red: 0.10, green: 0.44, blue: 0.30)
        case .dragHover: return Color(red: 0.56, green: 0.24, blue: 0.12)
        case .expanded: return Color(red: 0.18, green: 0.22, blue: 0.46)
        }
    }

    private var iconName: String? {
        switch state {
        case .idle, .clipboardChanged: return nil
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
