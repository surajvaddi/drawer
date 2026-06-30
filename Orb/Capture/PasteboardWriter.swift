import AppKit
import Foundation

struct PasteboardWriter: Sendable {
    let pasteboard: PasteboardProviding

    init(pasteboard: PasteboardProviding = NSPasteboard.general) {
        self.pasteboard = pasteboard
    }

    func write(item: Item, blobData: Data? = nil) throws {
        pasteboard.clearContents()
        switch item.type {
        case .url:
            let url = item.sourceURL ?? item.contentText ?? item.title
            pasteboard.setString(url, forType: .string)
            pasteboard.setString(url, forType: .URL)
        case .image, .screenshot:
            if let blobData {
                pasteboard.setData(blobData, forType: .png)
            } else if let text = item.contentText {
                pasteboard.setString(text, forType: .string)
            }
        case .file:
            if let path = item.contentText {
                pasteboard.setString(path, forType: .fileURL)
                pasteboard.setString(path, forType: .string)
            }
        default:
            pasteboard.setString(item.contentText ?? item.preview, forType: .string)
            if let html = item.contentHTML {
                pasteboard.setString(html, forType: .html)
            }
        }
    }
}
