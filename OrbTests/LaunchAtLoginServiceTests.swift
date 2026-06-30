import XCTest
@testable import Orb

final class LaunchAtLoginServiceTests: XCTestCase {
    func testLaunchAtLoginTogglePersists() {
        let key = "orb.launch_at_login"
        let defaults = UserDefaults(suiteName: "orb.launch.\(UUID().uuidString)")!
        defaults.removeObject(forKey: key)
        defaults.set(true, forKey: key)
        XCTAssertTrue(defaults.bool(forKey: key))
        defaults.set(false, forKey: key)
        XCTAssertFalse(defaults.bool(forKey: key))
    }
}
