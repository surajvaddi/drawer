import AppKit
import Foundation

struct ThumbnailGenerator: Sendable {
    let maxDimension: CGFloat

    init(maxDimension: CGFloat = 256) {
        self.maxDimension = maxDimension
    }

    func generatePNG(from imageData: Data) throws -> Data {
        guard let image = NSImage(data: imageData) else {
            throw OrbError.invalidData("Unable to decode image data")
        }
        let resized = resize(image: image, maxDimension: maxDimension)
        guard
            let tiff = resized.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else {
            throw OrbError.invalidData("Unable to encode PNG thumbnail")
        }
        return png
    }

    func generatePNG(from image: NSImage) throws -> Data {
        let resized = resize(image: image, maxDimension: maxDimension)
        guard
            let tiff = resized.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else {
            throw OrbError.invalidData("Unable to encode PNG thumbnail")
        }
        return png
    }

    private func resize(image: NSImage, maxDimension: CGFloat) -> NSImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1)
        let newSize = NSSize(width: size.width * scale, height: size.height * scale)
        let output = NSImage(size: newSize)
        output.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize), from: .zero, operation: .copy, fraction: 1)
        output.unlockFocus()
        return output
    }
}
