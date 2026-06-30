import Foundation

enum ItemType: String, Codable, CaseIterable, Sendable {
    case text
    case url
    case image
    case screenshot
    case file
    case pdf
    case code
    case html
    case fact
    case richClip = "rich_clip"

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .url: return "Link"
        case .image: return "Image"
        case .screenshot: return "Screenshot"
        case .file: return "File"
        case .pdf: return "PDF"
        case .code: return "Code"
        case .html: return "HTML"
        case .fact: return "Fact"
        case .richClip: return "Rich Clip"
        }
    }

    var iconName: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .image, .screenshot: return "photo"
        case .file, .pdf: return "doc"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .html: return "doc.richtext"
        case .fact: return "lightbulb"
        case .richClip: return "doc.on.clipboard"
        }
    }
}

enum SensitivityLevel: String, Codable, CaseIterable, Sendable, Comparable {
    case normal
    case sensitive
    case privateContent = "private"

    private var sortOrder: Int {
        switch self {
        case .normal: return 0
        case .sensitive: return 1
        case .privateContent: return 2
        }
    }

    static func < (lhs: SensitivityLevel, rhs: SensitivityLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum CaptureMethod: String, Codable, CaseIterable, Sendable {
    case clipboardSave = "clipboard_save"
    case clipboardDetected = "clipboard_detected"
    case dragDrop = "drag_drop"
    case screenshot
    case fileImport = "file_import"
    case manualNote = "manual_note"
    case shareExtension = "share_extension"

    var displayName: String {
        switch self {
        case .clipboardSave: return "Clipboard Save"
        case .clipboardDetected: return "Clipboard Detected"
        case .dragDrop: return "Drag and Drop"
        case .screenshot: return "Screenshot"
        case .fileImport: return "File Import"
        case .manualNote: return "Manual Note"
        case .shareExtension: return "Share Extension"
        }
    }
}
