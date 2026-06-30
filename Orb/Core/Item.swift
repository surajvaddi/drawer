import Foundation

struct Item: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var type: ItemType
    var title: String
    var preview: String
    var contentText: String?
    var contentHTML: String?
    var sourceURL: String?
    var sourceApp: String?
    var sourceWindowTitle: String?
    var originalCreatedAt: Date?
    var createdAt: Date
    var updatedAt: Date
    var lastAccessedAt: Date?
    var drawerId: String?
    var isPinned: Bool
    var isFavorite: Bool
    var isArchived: Bool
    var sensitivity: SensitivityLevel
    var userNote: String?
    var sortOrder: Int

    static let previewLimit = 240

    init(
        id: String = UUID().uuidString,
        type: ItemType,
        title: String,
        preview: String = "",
        contentText: String? = nil,
        contentHTML: String? = nil,
        sourceURL: String? = nil,
        sourceApp: String? = nil,
        sourceWindowTitle: String? = nil,
        originalCreatedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastAccessedAt: Date? = nil,
        drawerId: String? = nil,
        isPinned: Bool = false,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        sensitivity: SensitivityLevel = .normal,
        userNote: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.preview = preview
        self.contentText = contentText
        self.contentHTML = contentHTML
        self.sourceURL = sourceURL
        self.sourceApp = sourceApp
        self.sourceWindowTitle = sourceWindowTitle
        self.originalCreatedAt = originalCreatedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastAccessedAt = lastAccessedAt
        self.drawerId = drawerId
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.sensitivity = sensitivity
        self.userNote = userNote
        self.sortOrder = sortOrder
    }

    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        preview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (contentText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    func previewText(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > Self.previewLimit else { return trimmed }
        let index = trimmed.index(trimmed.startIndex, offsetBy: Self.previewLimit)
        return String(trimmed[..<index]) + "…"
    }
}
