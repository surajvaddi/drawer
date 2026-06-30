import XCTest
@testable import Orb

final class EmbeddingProviderIntegrationTests: XCTestCase {
    func testEmbeddingProviderHandlesBatch() async throws {
        let provider = MockEmbeddingProvider()
        let texts = ["alpha", "beta", "gamma"]
        var vectors: [[Double]] = []
        for text in texts {
            vectors.append(try await provider.embed(text: text))
        }
        XCTAssertEqual(vectors.count, 3)
        XCTAssertEqual(vectors[0].count, vectors[1].count)
    }
}
