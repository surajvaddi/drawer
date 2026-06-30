import AppKit
import Foundation

struct PasteboardClassifier: Sendable {
    func classify(types: [NSPasteboard.PasteboardType]) -> [ItemType] {
        let typeStrings = Set(types.map(\.rawValue))
        var candidates: [ItemType] = []

        if typeStrings.contains(NSPasteboard.PasteboardType.fileURL.rawValue) {
            candidates.append(.file)
        }
        if typeStrings.contains(NSPasteboard.PasteboardType.png.rawValue)
            || typeStrings.contains(NSPasteboard.PasteboardType.tiff.rawValue) {
            candidates.append(.image)
        }
        if typeStrings.contains(NSPasteboard.PasteboardType.html.rawValue) {
            candidates.append(.html)
            candidates.append(.richClip)
        }
        if typeStrings.contains(NSPasteboard.PasteboardType.string.rawValue) {
            candidates.append(.text)
            candidates.append(.url)
            candidates.append(.code)
        }
        if candidates.isEmpty {
            candidates.append(.text)
        }
        return orderedUnique(candidates)
    }

    func primaryType(from types: [NSPasteboard.PasteboardType], text: String?) -> ItemType {
        let candidates = classify(types: types)
        if let text, URLNormalizer.isURL(text) { return .url }
        if candidates.contains(.file) { return .file }
        if candidates.contains(.image) { return .image }
        if let text, CodeSnippetDetector().isCode(text) { return .code }
        if candidates.contains(.html) { return .html }
        return candidates.first ?? .text
    }

    private func orderedUnique(_ types: [ItemType]) -> [ItemType] {
        var seen = Set<ItemType>()
        return types.filter { seen.insert($0).inserted }
    }
}
