import AppKit
import Foundation

struct PasteboardPayload: Equatable, Sendable {
    var types: [String]
    var text: String?
    var html: String?
    var url: String?
    var imageData: Data?
    var fileURLs: [URL]
}

struct PasteboardReader: Sendable {
    let pasteboard: PasteboardProviding

    init(pasteboard: PasteboardProviding = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }

    func read() -> PasteboardPayload {
        let types = pasteboard.types?.map(\.rawValue) ?? []
        let text = pasteboard.string(forType: .string)
        let html = pasteboard.string(forType: .html)
        let url = pasteboard.string(forType: .URL) ?? text.flatMap { URLNormalizer.isURL($0) ? URLNormalizer.normalize($0) : nil }
        let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff)
        let fileURLs = readFileURLs()
        return PasteboardPayload(
            types: types,
            text: text,
            html: html,
            url: url,
            imageData: imageData,
            fileURLs: fileURLs
        )
    }

    private func readFileURLs() -> [URL] {
        if let raw = pasteboard.string(forType: .fileURL) {
            return [URL(fileURLWithPath: raw)]
        }
        guard let pasteboard = pasteboard as? NSPasteboard else { return [] }
        return pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] ?? []
    }
}
