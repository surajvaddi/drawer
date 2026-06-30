import XCTest
@testable import Orb

final class LinkItemActionsIntegrationTests: XCTestCase {
    func testOpenLinkActionLaunchesBrowser() throws {
        let opener = MockWorkspaceOpener()
        let actions = LinkItemActions(pasteboard: MockPasteboard(), workspace: opener)
        let item = Item(type: .url, title: "Example", sourceURL: "https://example.com")
        try actions.openInBrowser(item)
        XCTAssertEqual(opener.openedURLs.count, 1)
    }
}
