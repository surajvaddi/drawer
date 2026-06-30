import XCTest
@testable import Orb

final class OrbViewIntegrationTests: XCTestCase {
    func testOrbViewSnapshotIdleState() {
        let view = OrbView(diameter: 48, state: .idle)
        XCTAssertEqual(view.state, .idle)
        XCTAssertEqual(view.pulseScale, 1)
    }
}
