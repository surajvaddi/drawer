import XCTest
@testable import Orb

final class SourceAppResolverTests: XCTestCase {
    func testResolveBundleID() {
        let info = SourceAppResolver().resolve()
        XCTAssertNotNil(info.name)
    }

    func testGracefulFallbackWhenUnknown() {
        let info = SourceAppInfo()
        XCTAssertNil(info.bundleID)
        XCTAssertNil(info.name)
    }
}
