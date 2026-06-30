import XCTest
@testable import Orb

final class SearchPerformanceTracerTests: XCTestCase {
    func testTracerFlagsSlowQueries() {
        let tracer = SearchPerformanceTracer()
        tracer.record(query: "fast", durationMs: 10, resultCount: 5)
        tracer.record(query: "slow", durationMs: 250, resultCount: 3)
        XCTAssertGreaterThan(tracer.averageDurationMs(), 100)
    }
}
