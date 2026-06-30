import XCTest
@testable import Orb

final class PasteboardClassifierIntegrationTests: XCTestCase {
    func testClassifyRealPasteboardFixtureSet() {
        let mock = MockPasteboard()
        mock.setFixture(text: "https://kinddesigns.com", url: "https://kinddesigns.com")
        let payload = PasteboardReader(pasteboard: mock).read()
        let types = payload.types.map { NSPasteboard.PasteboardType($0) }
        let primary = PasteboardClassifier().primaryType(from: types, text: payload.text)
        XCTAssertEqual(primary, .url)
    }
}

import AppKit
