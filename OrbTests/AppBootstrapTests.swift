import XCTest
@testable import Orb

final class AppBootstrapTests: XCTestCase {
    func testAppDelegateInitializesWithoutCrash() {
        let delegate = AppDelegate()
        XCTAssertNotNil(delegate)
        delegate.applicationDidFinishLaunching(Notification(name: .init("test")))
    }

    func testBundleIdentifierIsSet() {
        let bundleID = Bundle.main.bundleIdentifier
        XCTAssertNotNil(bundleID)
        XCTAssertFalse(bundleID?.isEmpty ?? true)
    }
}
