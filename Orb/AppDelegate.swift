import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var orbPanel: FloatingOrbPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        OrbLogger.shared.info("Orb application did finish launching")
        showPersistentOrb()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    private func showPersistentOrb() {
        let size = NSSize(width: 72, height: 72)
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 900, height: 700)
        let origin = NSPoint(
            x: visibleFrame.maxX - size.width - 32,
            y: visibleFrame.maxY - size.height - 72
        )
        let panel = FloatingOrbPanel(contentRect: NSRect(origin: origin, size: size))
        panel.contentView = NSHostingView(
            rootView: PersistentOrbButton {
                self.showMainWindow()
            }
        )
        panel.orderFrontRegardless()
        orbPanel = panel
    }

    private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let mainWindow = NSApp.windows.first(where: { window in
            !(window is FloatingOrbPanel) && window.isVisible
        }) {
            mainWindow.makeKeyAndOrderFront(nil)
        } else {
            NSApp.sendAction(#selector(AppDelegate.showMainWindowAction), to: nil, from: nil)
        }
    }

    @objc private func showMainWindowAction() {}
}

private struct PersistentOrbButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            OrbView(diameter: 64, state: .idle)
                .padding(4)
        }
        .buttonStyle(.plain)
        .help("Open Orb")
    }
}
