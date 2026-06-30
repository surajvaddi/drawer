import Foundation

struct TextNormalizer: Sendable {
    func normalize(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "[ \t]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func preview(from text: String, limit: Int = Item.previewLimit) -> String {
        let normalized = normalize(text)
        guard normalized.count > limit else { return normalized }
        let index = normalized.index(normalized.startIndex, offsetBy: limit)
        return String(normalized[..<index]) + "…"
    }

    func title(from text: String) -> String {
        let firstLine = normalize(text).split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
        return firstLine.isEmpty ? "Text Snippet" : String(firstLine.prefix(80))
    }
}
