import Foundation

enum BlobKind: String, Codable, CaseIterable, Sendable {
    case original
    case thumbnail
    case preview
    case ocr
    case embedding

    var folderName: String {
        switch self {
        case .original: return "originals"
        case .thumbnail: return "thumbnails"
        case .preview: return "previews"
        case .ocr: return "ocr"
        case .embedding: return "vector"
        }
    }
}

struct Blob: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var itemId: String
    var kind: BlobKind
    var localPath: String
    var mimeType: String
    var sizeBytes: Int64
    var checksum: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        itemId: String,
        kind: BlobKind,
        localPath: String,
        mimeType: String,
        sizeBytes: Int64,
        checksum: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.kind = kind
        self.localPath = localPath
        self.mimeType = mimeType
        self.sizeBytes = sizeBytes
        self.checksum = checksum
        self.createdAt = createdAt
    }
}

struct Embedding: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var itemId: String
    var model: String
    var vector: [Double]
    var textHash: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        itemId: String,
        model: String,
        vector: [Double],
        textHash: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.model = model
        self.vector = vector
        self.textHash = textHash
        self.createdAt = createdAt
    }

    var isValid: Bool {
        !vector.isEmpty && vector.allSatisfy { $0.isFinite }
    }
}

struct CaptureEvent: Identifiable, Codable, Equatable, Sendable {
    var id: String
    var itemId: String
    var method: CaptureMethod
    var sourceApp: String?
    var pasteboardTypes: [String]
    var rawMetadata: [String: String]
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        itemId: String,
        method: CaptureMethod,
        sourceApp: String? = nil,
        pasteboardTypes: [String] = [],
        rawMetadata: [String: String] = [:],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.method = method
        self.sourceApp = sourceApp
        self.pasteboardTypes = pasteboardTypes
        self.rawMetadata = rawMetadata
        self.createdAt = createdAt
    }
}
