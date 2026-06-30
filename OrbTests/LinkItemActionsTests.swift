import XCTest
@testable import Orb

final class LinkItemActionsTests: XCTestCase {
    func testCopyMarkdownLinkFormat() throws {
        let pasteboard = MockPasteboard()
        let actions = LinkItemActions(pasteboard: pasteboard)
        let item = Item(type: .url, title: "Example", preview: "https://example.com", contentText: "https://example.com", sourceURL: "https://example.com")
        try actions.copyMarkdownLink(item)
        XCTAssertEqual(pasteboard.string(forType: .string), "[Example](https://example.com)")
    }

    func testOpenURLUsesNSWorkspace() throws {
        let opener = MockWorkspaceOpener()
        let actions = LinkItemActions(pasteboard: MockPasteboard(), workspace: opener)
        let item = Item(type: .url, title: "Example", sourceURL: "https://example.com")
        try actions.openInBrowser(item)
        XCTAssertEqual(opener.openedURLs.first?.absoluteString, "https://example.com")
    }
}
