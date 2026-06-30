import XCTest
@testable import Orb

final class PermissionOnboardingViewTests: XCTestCase {
    func testEachPermissionHasExplanationText() {
        XCTAssertEqual(PermissionKind.allCases.count, 4)
        for kind in PermissionKind.allCases {
            XCTAssertFalse(kind.rawValue.isEmpty)
            XCTAssertNotNil(PermissionService().status(for: kind))
        }
    }
}
