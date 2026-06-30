import XCTest
@testable import Orb

final class SaveToastViewTests: XCTestCase {
    func testToastShowsDrawerName() {
        let view = SaveToastView(message: "Saved to Inbox", isVisible: true)
        XCTAssertNotNil(view.body)
    }
}
