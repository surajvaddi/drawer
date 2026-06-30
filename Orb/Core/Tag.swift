import Foundation

struct Tag: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var name: String
    var color: String?

    init(id: String = UUID().uuidString, name: String, color: String? = nil) {
        self.id = id
        self.name = Tag.normalize(name)
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = Tag.normalize(try container.decode(String.self, forKey: .name))
        color = try container.decodeIfPresent(String.self, forKey: .color)
    }

    static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

struct ItemTag: Codable, Equatable, Sendable {
    var itemId: String
    var tagId: String
}
