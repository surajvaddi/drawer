import Foundation

struct DrawerRule: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var drawerId: String
    var name: String
    var condition: [String: String]
    var priority: Int
    var enabled: Bool

    init(
        id: String = UUID().uuidString,
        drawerId: String,
        name: String,
        condition: [String: String],
        priority: Int = 0,
        enabled: Bool = true
    ) {
        self.id = id
        self.drawerId = drawerId
        self.name = name
        self.condition = condition
        self.priority = priority
        self.enabled = enabled
    }
}

enum AIAnnotationKind: String, Codable, CaseIterable, Sendable {
    case title
    case summary
    case tags
    case facts
    case drawerSuggestion = "drawer_suggestion"
    case entities
}

struct AIAnnotation: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var itemId: String
    var kind: AIAnnotationKind
    var model: String
    var content: [String: String]
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        itemId: String,
        kind: AIAnnotationKind,
        model: String,
        content: [String: String],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.kind = kind
        self.model = model
        self.content = content
        self.createdAt = createdAt
    }
}
