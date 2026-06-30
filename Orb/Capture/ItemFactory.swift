import Foundation

struct CapturePayload: Sendable {
    var type: ItemType
    var title: String
    var preview: String
    var contentText: String?
    var contentHTML: String?
    var sourceURL: String?
    var blobData: Data?
    var mimeType: String?
    var sourceApp: String?
    var sourceWindowTitle: String?
    var method: CaptureMethod
}

struct ItemFactory: Sendable {
    let defaultDrawerID: String?

    init(defaultDrawerID: String? = DefaultDataSeeder.inboxDrawerID) {
        self.defaultDrawerID = defaultDrawerID
    }

    func makeItem(from payload: CapturePayload) -> Item {
        Item(
            type: payload.type,
            title: payload.title,
            preview: payload.preview,
            contentText: payload.contentText,
            contentHTML: payload.contentHTML,
            sourceURL: payload.sourceURL,
            sourceApp: payload.sourceApp,
            sourceWindowTitle: payload.sourceWindowTitle,
            drawerId: defaultDrawerID
        )
    }

    func makeItem(from pasteboard: PasteboardPayload, sourceApp: String? = nil) -> CapturePayload {
        let classifier = PasteboardClassifier()
        let types = pasteboard.types.map { NSPasteboard.PasteboardType($0) }
        let primary = classifier.primaryType(from: types, text: pasteboard.text)
        let textNormalizer = TextNormalizer()

        switch primary {
        case .url:
            let url = URLNormalizer.normalize(pasteboard.url ?? pasteboard.text ?? "")
            return CapturePayload(
                type: .url,
                title: URLNormalizer.domain(from: url) ?? url,
                preview: url,
                contentText: url,
                sourceURL: url,
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        case .image:
            return CapturePayload(
                type: .screenshot,
                title: "Clipboard Image",
                preview: "Image from clipboard",
                blobData: pasteboard.imageData,
                mimeType: "image/png",
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        case .file:
            let path = pasteboard.fileURLs.first?.lastPathComponent ?? "File"
            return CapturePayload(
                type: .file,
                title: path,
                preview: path,
                contentText: pasteboard.fileURLs.first?.path,
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        case .code:
            let text = textNormalizer.normalize(pasteboard.text ?? "")
            return CapturePayload(
                type: .code,
                title: "Code Snippet",
                preview: textNormalizer.preview(from: text),
                contentText: text,
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        case .html, .richClip:
            let text = textNormalizer.normalize(pasteboard.text ?? "")
            return CapturePayload(
                type: .richClip,
                title: textNormalizer.title(from: text),
                preview: textNormalizer.preview(from: text),
                contentText: text,
                contentHTML: pasteboard.html,
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        default:
            let text = textNormalizer.normalize(pasteboard.text ?? "")
            return CapturePayload(
                type: .text,
                title: textNormalizer.title(from: text),
                preview: textNormalizer.preview(from: text),
                contentText: text,
                sourceApp: sourceApp,
                method: .clipboardSave
            )
        }
    }
}

import AppKit
