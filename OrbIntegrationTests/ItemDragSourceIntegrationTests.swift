import XCTest
@testable import Orb

final class ItemDragSourceIntegrationTests: XCTestCase {
    func testDragSnippetIntoTextEdit() throws {
        let pasteboard = MockPasteboard()
        let source = ItemDragSource(writer: PasteboardWriter(pasteboard: pasteboard))
        let item = Item(type: .text, title: "Snippet", contentText: "drag me out")
        try source.writeToPasteboard(item: item)
        XCTAssertEqual(pasteboard.string(forType: .string), "drag me out")
    }
}
