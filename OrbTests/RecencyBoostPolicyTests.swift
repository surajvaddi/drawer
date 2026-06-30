import XCTest
@testable import Orb

final class RecencyBoostPolicyTests: XCTestCase {
    func testRecentAccessIncreasesScore() {
        let policy = RecencyBoostPolicy()
        let recent = Item(type: .text, title: "A", lastAccessedAt: Date())
        let old = Item(type: .text, title: "B", lastAccessedAt: Date(timeIntervalSince1970: 1))
        XCTAssertGreaterThan(policy.score(for: recent), policy.score(for: old))
    }

    func testBoostDecaysOverTime() {
        let policy = RecencyBoostPolicy()
        let now = Date()
        let recent = policy.score(for: Item(type: .text, title: "A", lastAccessedAt: now), now: now)
        let old = policy.score(for: Item(type: .text, title: "A", lastAccessedAt: now.addingTimeInterval(-72 * 3600)), now: now)
        XCTAssertGreaterThan(recent, old)
    }
}
