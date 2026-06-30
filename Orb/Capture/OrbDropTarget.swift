import AppKit
import UniformTypeIdentifiers

struct OrbDropTarget: Sendable {
    static let acceptedTypes: [UTType] = [.plainText, .url, .fileURL, .png, .jpeg, .pdf, .utf8PlainText]

    func accepts(_ types: [String]) -> Bool {
        let accepted = Set(Self.acceptedTypes.map(\.identifier))
        return types.contains { accepted.contains($0) || $0 == NSPasteboard.PasteboardType.string.rawValue }
    }

    func rejectsUnsupported(_ types: [String]) -> Bool {
        !accepts(types)
    }
}
