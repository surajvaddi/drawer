import XCTest

final class BlobModelIntegrationTests: XCTestCase {
    func testCaptureEventRoundTripThroughJSON() throws {
        let event = CaptureEvent(
            itemId: "item",
            method: .clipboardSave,
            sourceApp: "Safari",
            pasteboardTypes: ["public.url"]
        )
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(CaptureEvent.self, from: data)
        XCTAssertEqual(decoded.method, .clipboardSave)
        XCTAssertEqual(decoded.pasteboardTypes, ["public.url"])
    }
}
