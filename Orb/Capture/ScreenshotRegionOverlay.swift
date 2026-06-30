import AppKit
import CoreGraphics
import Foundation

struct ScreenshotSelection: Equatable, Sendable {
    var rect: CGRect
    var cancelled: Bool
}

struct ScreenshotRegionOverlay: Sendable {
    func clampedSelection(_ rect: CGRect, to screenBounds: CGRect) -> CGRect {
        guard !screenBounds.isNull, screenBounds.width > 0, screenBounds.height > 0 else { return rect }
        var clamped = rect.standardized
        clamped.origin.x = max(screenBounds.minX, min(clamped.origin.x, screenBounds.maxX))
        clamped.origin.y = max(screenBounds.minY, min(clamped.origin.y, screenBounds.maxY))
        clamped.size.width = min(clamped.width, screenBounds.maxX - clamped.origin.x)
        clamped.size.height = min(clamped.height, screenBounds.maxY - clamped.origin.y)
        clamped.size.width = max(0, clamped.size.width)
        clamped.size.height = max(0, clamped.size.height)
        return clamped
    }

    func selection(from start: CGPoint, to end: CGPoint, screenBounds: CGRect) -> ScreenshotSelection {
        let rect = CGRect(x: min(start.x, end.x), y: min(start.y, end.y), width: abs(end.x - start.x), height: abs(end.y - start.y))
        return ScreenshotSelection(rect: clampedSelection(rect, to: screenBounds), cancelled: false)
    }

    func cancelSelection() -> ScreenshotSelection {
        ScreenshotSelection(rect: .zero, cancelled: true)
    }
}
