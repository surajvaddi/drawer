import Foundation

struct Drawer: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var name: String
    var icon: String?
    var color: String?
    var parentDrawerId: String?
    var description: String?
    var sortOrder: Int
    var isPinned: Bool
    var isPrivate: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        name: String,
        icon: String? = nil,
        color: String? = nil,
        parentDrawerId: String? = nil,
        description: String? = nil,
        sortOrder: Int = 0,
        isPinned: Bool = false,
        isPrivate: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.parentDrawerId = parentDrawerId
        self.description = description
        self.sortOrder = sortOrder
        self.isPinned = isPinned
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func path(in drawers: [Drawer]) -> String {
        var parts = [name]
        var currentParent = parentDrawerId
        let byID = Dictionary(uniqueKeysWithValues: drawers.map { ($0.id, $0) })
        while let parentID = currentParent, let parent = byID[parentID] {
            parts.insert(parent.name, at: 0)
            currentParent = parent.parentDrawerId
        }
        return parts.joined(separator: " / ")
    }

    static func sortByOrder(_ lhs: Drawer, _ rhs: Drawer) -> Bool {
        if lhs.sortOrder == rhs.sortOrder {
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
        return lhs.sortOrder < rhs.sortOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        parentDrawerId = try container.decodeIfPresent(String.self, forKey: .parentDrawerId)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
