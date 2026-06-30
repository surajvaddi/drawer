import XCTest
@testable import Orb

final class BlobModelTests: XCTestCase {
    func testBlobKindPaths() {
        XCTAssertEqual(BlobKind.thumbnail.folderName, "thumbnails")
        XCTAssertEqual(BlobKind.ocr.folderName, "ocr")
    }

    func testEmbeddingVectorValidation() {
        let valid = Embedding(itemId: "i", model: "m", vector: [0.1, 0.2], textHash: "h")
        XCTAssertTrue(valid.isValid)
        let invalid = Embedding(itemId: "i", model: "m", vector: [], textHash: "h")
        XCTAssertFalse(invalid.isValid)
    }

    func testCaptureEventMetadataEncoding() throws {
        let event = CaptureEvent(itemId: "i", method: .screenshot, rawMetadata: ["key": "value"])
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(CaptureEvent.self, from: data)
        XCTAssertEqual(decoded.rawMetadata["key"], "value")
    }
}
