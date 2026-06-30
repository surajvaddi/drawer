import XCTest
@testable import Orb

final class AppLaunchIntegrationTests: XCTestCase {
    func testAppLaunchesInTestHarness() {
        let delegate = AppDelegate()
        XCTAssertNotNil(delegate)
        XCTAssertTrue(delegate.applicationSupportsSecureRestorableState(NSApplication.shared))
    }
}
