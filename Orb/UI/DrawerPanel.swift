import AppKit

final class DrawerPanel: NSPanel {
    static let defaultWidth: CGFloat = 360
    static let maxHeightRatio: CGFloat = 0.8

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        isMovableByWindowBackground = true
    }

    func anchor(near orbOrigin: NSPoint, orbSize: NSSize, on screen: NSScreen?) {
        let screenFrame = screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let height = min(640, screenFrame.height * Self.maxHeightRatio)
        let x = min(max(orbOrigin.x + orbSize.width + 12, screenFrame.minX), screenFrame.maxX - Self.defaultWidth)
        let y = min(max(orbOrigin.y, screenFrame.minY), screenFrame.maxY - height)
        setFrame(NSRect(x: x, y: y, width: Self.defaultWidth, height: height), display: true)
    }
}
