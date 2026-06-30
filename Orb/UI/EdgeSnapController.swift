import AppKit

struct EdgeSnapController: Sendable {
    let threshold: CGFloat
    let enabled: Bool

    init(threshold: CGFloat = 24, enabled: Bool = true) {
        self.threshold = threshold
        self.enabled = enabled
    }

    func snappedOrigin(for origin: NSPoint, windowSize: NSSize, in screen: NSScreen?) -> NSPoint {
        guard enabled, let frame = screen?.visibleFrame ?? NSScreen.main?.visibleFrame else {
            return origin
        }
        var point = origin
        if abs(point.x - frame.minX) <= threshold { point.x = frame.minX }
        if abs(point.y - frame.minY) <= threshold { point.y = frame.minY }
        if abs((point.x + windowSize.width) - frame.maxX) <= threshold {
            point.x = frame.maxX - windowSize.width
        }
        if abs((point.y + windowSize.height) - frame.maxY) <= threshold {
            point.y = frame.maxY - windowSize.height
        }
        return point
    }
}
