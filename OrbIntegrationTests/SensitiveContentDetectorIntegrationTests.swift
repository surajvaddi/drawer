import XCTest
@testable import Orb

final class SensitiveContentDetectorIntegrationTests: XCTestCase {
    func testDetectorRunsOnClipboardBeforeSave() throws {
        let mock = MockPasteboard()
        mock.setFixture(text: "AKIAIOSFODNN7EXAMPLE")
        let payload = PasteboardReader(pasteboard: mock).read()
        let findings = SensitiveContentDetector().detect(in: payload.text ?? "")
        XCTAssertFalse(findings.isEmpty)
    }
}
