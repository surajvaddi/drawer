import Foundation

struct ParsedSearchFilters: Equatable, Sendable {
    var text: String = ""
    var types: Set<ItemType> = []
    var drawerIDs: Set<String> = []
    var tags: Set<String> = []
    var sourceApps: Set<String> = []
    var after: Date?
    var before: Date?
}

struct SearchFilterParser: Sendable {
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()

    func parse(_ query: String) -> ParsedSearchFilters {
        var filters = ParsedSearchFilters()
        var textParts: [String] = []
        for token in query.split(whereSeparator: { $0.isWhitespace }).map(String.init) {
            if token.hasPrefix("type:"), let raw = token.split(separator: ":").last, let type = ItemType(rawValue: String(raw)) {
                filters.types.insert(type)
            } else if token.hasPrefix("drawer:"), let id = token.split(separator: ":").last {
                filters.drawerIDs.insert(String(id))
            } else if token.hasPrefix("tag:"), let tag = token.split(separator: ":").last {
                filters.tags.insert(Tag.normalize(String(tag)))
            } else if token.hasPrefix("source:"), let app = token.split(separator: ":").last {
                filters.sourceApps.insert(String(app).lowercased())
            } else if token.hasPrefix("after:"), let raw = token.split(separator: ":").last {
                filters.after = dateFormatter.date(from: String(raw))
            } else if token.hasPrefix("before:"), let raw = token.split(separator: ":").last {
                filters.before = dateFormatter.date(from: String(raw))
            } else {
                textParts.append(token)
            }
        }
        filters.text = textParts.joined(separator: " ")
        return filters
    }
}
