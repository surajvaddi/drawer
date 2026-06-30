import AppKit
import CoreGraphics
import Foundation

struct ScreenshotCaptureService: Sendable {
  func captureRegion(_ rect: CGRect, scale: CGFloat = NSScreen.main?.backingScaleFactor ?? 2) throws -> Data {
        let bounds = rect.integral
        guard bounds.width > 0, bounds.height > 0 else {
            throw OrbError.invalidData("Capture region must be non-zero")
        }
        guard let image = CGWindowListCreateImage(bounds, .optionOnScreenOnly, kCGNullWindowID, [.bestResolution]) else {
            throw OrbError.invalidData("Unable to capture screen region")
        }
        let bitmap = NSBitmapImageRep(cgImage: image)
        bitmap.size = NSSize(width: bounds.width, height: bounds.height)
        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            throw OrbError.invalidData("Unable to encode screenshot PNG")
        }
        if scale > 1, let decoded = NSImage(data: png) {
            decoded.size = NSSize(width: bounds.width / scale, height: bounds.height / scale)
            if let tiff = decoded.tiffRepresentation,
               let scaledBitmap = NSBitmapImageRep(data: tiff),
               let scaledPNG = scaledBitmap.representation(using: .png, properties: [:]) {
                return scaledPNG
            }
        }
        return png
    }
}
