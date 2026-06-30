import SwiftUI

struct SaveToastView: View {
    let message: String
    var isVisible: Bool

    var body: some View {
        if isVisible {
            Text(message)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(radius: 4, y: 2)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct SaveToastModifier: ViewModifier {
    @Binding var isVisible: Bool
    let message: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                SaveToastView(message: message, isVisible: isVisible)
                    .padding(.top, 8)
            }
            .onChange(of: isVisible) { _, visible in
                guard visible else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(OrbAnimationPolish.toastDismiss) {
                        isVisible = false
                    }
                }
            }
    }
}

extension View {
    func saveToast(isVisible: Binding<Bool>, message: String, duration: TimeInterval = 2) -> some View {
        modifier(SaveToastModifier(isVisible: isVisible, message: message, duration: duration))
    }
}
