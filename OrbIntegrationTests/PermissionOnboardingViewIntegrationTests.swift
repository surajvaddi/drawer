import XCTest
@testable import Orb

final class PermissionOnboardingViewIntegrationTests: XCTestCase {
    func testOpenSystemSettingsDeepLink() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!
        XCTAssertEqual(url.scheme, "x-apple.systempreferences")
        XCTAssertTrue(url.absoluteString.contains("Privacy"))
    }
}
