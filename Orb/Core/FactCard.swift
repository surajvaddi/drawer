import Foundation

struct FactCard: Identifiable, Equatable, Sendable {
    var id: String
    var text: String
    var sourceItemId: String?
    var itemId: String

    init(id: String = UUID().uuidString, text: String, sourceItemId: String?, itemId: String) {
        self.id = id
        self.text = text
        self.sourceItemId = sourceItemId
        self.itemId = itemId
    }
}
