import XCTest
@testable import Orb

final class PasteboardReaderIntegrationTests: XCTestCase {
    func testReadFromSystemPasteboardMock() {
        let mock = MockPasteboard()
        mock.setFixture(text: "integration", url: "https://orb.test")
        let payload = PasteboardReader(pasteboard: mock).read()
        XCTAssertEqual(payload.text, "integration")
        XCTAssertEqual(payload.url, "https://orb.test")
    }
}
