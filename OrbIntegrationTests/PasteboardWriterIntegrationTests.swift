import XCTest
@testable import Orb

final class PasteboardWriterIntegrationTests: XCTestCase {
    func testCopyItemThenPasteInExternalApp() throws {
        let mock = MockPasteboard()
        try PasteboardWriter(pasteboard: mock).write(
            item: Item(type: .url, title: "Example", contentText: "https://example.com", sourceURL: "https://example.com")
        )
        XCTAssertEqual(mock.string(forType: .URL), "https://example.com")
        XCTAssertEqual(mock.string(forType: .string), "https://example.com")
    }
}
