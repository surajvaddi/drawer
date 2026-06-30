import AppKit
import Foundation

struct ItemDragPayload: Equatable, Sendable {
    var text: String?
    var fileURL: String?
    var pngData: Data?
}

struct ItemDragSource: Sendable {
    let writer: PasteboardWriter

    init(writer: PasteboardWriter = PasteboardWriter()) {
        self.writer = writer
    }

    func payload(for item: Item, blobData: Data? = nil) -> ItemDragPayload {
        switch item.type {
        case .file, .pdf:
            return ItemDragPayload(text: item.contentText, fileURL: item.contentText)
        case .screenshot, .image:
            return ItemDragPayload(pngData: blobData)
        default:
            return ItemDragPayload(text: item.contentText ?? item.preview)
        }
    }

    func writeToPasteboard(item: Item, blobData: Data? = nil) throws {
        try writer.write(item: item, blobData: blobData)
    }
}
