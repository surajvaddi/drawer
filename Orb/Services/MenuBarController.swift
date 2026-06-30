import AppKit

final class MenuBarController: NSObject, @unchecked Sendable {
    private var statusItem: NSStatusItem?
    private let onToggleDrawer: () -> Void
    private let onOpenLibrary: () -> Void
    private let onQuit: () -> Void

    init(
        onToggleDrawer: @escaping () -> Void,
        onOpenLibrary: @escaping () -> Void,
        onQuit: @escaping () -> Void = { NSApp.terminate(nil) }
    ) {
        self.onToggleDrawer = onToggleDrawer
        self.onOpenLibrary = onOpenLibrary
        self.onQuit = onQuit
    }

    func install() {
        guard statusItem == nil else { return }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: "Orb")
        statusItem?.menu = buildMenu()
    }

    func uninstall() {
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "Toggle Drawer", action: #selector(toggleDrawer), keyEquivalent: "d")
        menu.addItem(withTitle: "Open Library", action: #selector(openLibrary), keyEquivalent: "l")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Orb", action: #selector(quit), keyEquivalent: "q")
        menu.items.forEach { $0.target = self }
        return menu
    }

    @objc private func toggleDrawer() { onToggleDrawer() }
    @objc private func openLibrary() { onOpenLibrary() }
    @objc private func quit() { onQuit() }
}
