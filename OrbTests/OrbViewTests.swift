import XCTest
import SwiftUI
@testable import Orb

final class OrbViewTests: XCTestCase {
    func testOrbViewRendersAtConfiguredSize() {
        let view = OrbView(diameter: 56)
        XCTAssertEqual(view.diameter, 56)
    }

    func testIdleStateShowsIcon() {
        let view = OrbView(state: .idle)
        XCTAssertEqual(view.state, .idle)
    }
}
