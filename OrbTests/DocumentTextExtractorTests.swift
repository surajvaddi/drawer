import XCTest
@testable import Orb

final class DocumentTextExtractorTests: XCTestCase {
    func testExtractMarkdownFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("orb-\(UUID().uuidString).md")
        try "# Heading\nBody".data(using: .utf8)!.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let text = try DocumentTextExtractor().extract(from: url)
        XCTAssertTrue(text.contains("Heading"))
    }

    func testExtractCSVFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("orb-\(UUID().uuidString).csv")
        try "a,b,c".data(using: .utf8)!.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let text = try DocumentTextExtractor().extract(from: url)
        XCTAssertEqual(text, "a,b,c")
    }
}
