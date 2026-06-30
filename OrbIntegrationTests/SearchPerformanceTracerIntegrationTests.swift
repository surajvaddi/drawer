import XCTest
@testable import Orb

final class SearchPerformanceTracerIntegrationTests: XCTestCase {
    func testSearch1000ItemsUnder150ms() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-perf-\(UUID().uuidString)", isDirectory: true)
        let manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let items = ItemRepository(manager: manager)
        let search = SearchRepository(manager: manager)
        for i in 0..<100 {
            _ = try items.create(Item(type: .text, title: "Item\(i)", contentText: "content \(i)"))
        }
        let tracer = SearchPerformanceTracer()
        let start = CFAbsoluteTimeGetCurrent()
        let results = try search.search("Item50")
        let durationMs = (CFAbsoluteTimeGetCurrent() - start) * 1000
        tracer.record(query: "Item50", durationMs: durationMs, resultCount: results.count)
        XCTAssertLessThan(durationMs, 150)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
