import XCTest
@testable import Orb

final class AIProviderTests: XCTestCase {
    func testMockProviderReturnsDeterministicOutput() async throws {
        let provider = MockAIProvider()
        let text = "The quick brown fox jumps over the lazy dog"
        let title1 = try await provider.generateTitle(from: text)
        let title2 = try await provider.generateTitle(from: text)
        XCTAssertEqual(title1, title2)
        XCTAssertFalse(title1.isEmpty)
    }
}
