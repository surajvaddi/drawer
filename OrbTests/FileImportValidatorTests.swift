import XCTest
@testable import Orb

final class FileImportValidatorTests: XCTestCase {
    func testRejectOversizedFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("orb-big-\(UUID().uuidString).txt")
        let data = Data(repeating: 0x41, count: 1024)
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let validator = FileImportValidator(maxBytes: 100)
        let result = try validator.validate(url: url)
        XCTAssertFalse(result.allowed)
    }

    func testAcceptPDFAndMarkdown() throws {
        let pdfURL = FileManager.default.temporaryDirectory.appendingPathComponent("orb-\(UUID().uuidString).pdf")
        try TestFixtures.minimalPDFData().write(to: pdfURL)
        defer { try? FileManager.default.removeItem(at: pdfURL) }
        let validator = FileImportValidator()
        XCTAssertTrue(try validator.validate(url: pdfURL).allowed)

        let mdURL = FileManager.default.temporaryDirectory.appendingPathComponent("orb-\(UUID().uuidString).md")
        try "# Title".data(using: .utf8)!.write(to: mdURL)
        defer { try? FileManager.default.removeItem(at: mdURL) }
        XCTAssertTrue(try validator.validate(url: mdURL).allowed)
    }
}
