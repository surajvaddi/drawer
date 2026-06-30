import SwiftUI

struct QuickActionsRow: View {
    var onSaveClipboard: () -> Void = {}
    var onScreenshot: () -> Void = {}
    var onNewDrawer: () -> Void = {}

    var body: some View {
        HStack(spacing: 8) {
            actionButton("Save Clipboard", systemImage: "doc.on.clipboard", action: onSaveClipboard)
            actionButton("Screenshot", systemImage: "camera.viewfinder", action: onScreenshot)
            actionButton("New Drawer", systemImage: "folder.badge.plus", action: onNewDrawer)
        }
    }

    private func actionButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}
