import XCTest
@testable import Orb

final class ExcludedAppsManagerTests: XCTestCase {
    func testAddRemoveExcludedApp() {
        let defaults = UserDefaults(suiteName: "orb.excluded.\(UUID().uuidString)")!
        var manager = ExcludedAppsManager(defaults: defaults)
        manager.add("com.example.secret")
        XCTAssertTrue(manager.isExcluded("com.example.secret"))
        manager.remove("com.example.secret")
        XCTAssertFalse(manager.isExcluded("com.example.secret"))
    }

    func testExcludedAppBlocksClipboardPulse() {
        let settings = ClipboardWatchSettings(
            excludedBundleIDs: ["com.example.bank"],
            excludedAppsProvider: { "com.example.bank" }
        )
        XCTAssertTrue(settings.shouldIgnoreCurrentApp())
    }
}
