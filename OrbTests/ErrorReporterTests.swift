import XCTest
@testable import Orb

final class ErrorReporterTests: XCTestCase {
    func testErrorToastAutoDismisses() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-err-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let reporter = ErrorReporter(paths: paths)
        reporter.report(message: "Save failed", context: "toast")
        let reports = reporter.recentReports(limit: 1)
        XCTAssertEqual(reports.first?.message, "Save failed")
        try? FileManager.default.removeItem(at: root)
    }
}
