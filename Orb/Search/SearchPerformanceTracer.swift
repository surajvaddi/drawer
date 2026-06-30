import Foundation

struct SearchPerformanceTrace: Codable, Equatable, Sendable {
    var query: String
    var durationMs: Double
    var resultCount: Int
    var timestamp: Date
}

final class SearchPerformanceTracer: @unchecked Sendable {
    private(set) var traces: [SearchPerformanceTrace] = []
    private let maxTraces: Int

    init(maxTraces: Int = 100) {
        self.maxTraces = maxTraces
    }

    func record(query: String, durationMs: Double, resultCount: Int) {
        traces.append(SearchPerformanceTrace(query: query, durationMs: durationMs, resultCount: resultCount, timestamp: Date()))
        if traces.count > maxTraces {
            traces.removeFirst(traces.count - maxTraces)
        }
    }

    func averageDurationMs() -> Double {
        guard !traces.isEmpty else { return 0 }
        return traces.map(\.durationMs).reduce(0, +) / Double(traces.count)
    }
}
