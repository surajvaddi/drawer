import AppKit

final class QuickPastePanel: NSPanel {
    static let defaultSize = NSSize(width: 520, height: 360)
    private(set) var isOpen = false

    init() {
        super.init(
            contentRect: NSRect(origin: .zero, size: Self.defaultSize),
            styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        title = "Quick Paste"
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        center()
    }

    override var canBecomeKey: Bool { true }

    func openPanel() {
        isOpen = true
        makeKeyAndOrderFront(nil)
    }

    func closeOnEscape() {
        isOpen = false
        orderOut(nil)
    }
}
