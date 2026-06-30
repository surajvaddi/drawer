import XCTest
@testable import Orb

final class EmbeddingProviderTests: XCTestCase {
    func testMockEmbeddingDeterministicDimension() async throws {
        let provider = MockEmbeddingProvider()
        let v1 = try await provider.embed(text: "hello world")
        let v2 = try await provider.embed(text: "hello world")
        XCTAssertEqual(v1, v2)
        XCTAssertEqual(v1.count, 8)
    }
}
