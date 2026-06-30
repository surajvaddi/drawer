import XCTest
@testable import Orb

final class CodeSnippetDetectorIntegrationTests: XCTestCase {
    func testCodeClipboardClassifiedAsCodeItem() {
        let mock = MockPasteboard()
        mock.setFixture(text: "def run():\n    return 42")
        let payload = ItemFactory().makeItem(from: PasteboardReader(pasteboard: mock).read())
        XCTAssertEqual(payload.type, .code)
    }
}
