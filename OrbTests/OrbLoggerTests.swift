import XCTest
@testable import Orb

final class OrbLoggerTests: XCTestCase {
    func testLoggerFormatsMessages() {
        let formatted = OrbLogger.shared.formattedMessage("hello", category: .storage)
        XCTAssertEqual(formatted, "[storage] hello")
    }

    func testOrbErrorDescriptionsAreNonEmpty() {
        let errors: [OrbError] = [
            .storage("disk full"),
            .capture("clipboard empty"),
            .search("index missing"),
            .permissionDenied("accessibility"),
            .invalidData("bad url"),
            .notFound("item"),
            .unknown("oops")
        ]
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }
}
