import XCTest
@testable import Orb

final class PDFTextExtractorTests: XCTestCase {
    func testExtractTextFromPDFFixture() throws {
        let data = TestFixtures.minimalPDFData()
        let extraction = try PDFTextExtractor().extract(from: data)
        XCTAssertGreaterThanOrEqual(extraction.pageCount, 1)
        XCTAssertNotNil(extraction.text)
    }

    func testPageCountDetected() throws {
        let data = TestFixtures.minimalPDFData()
        let extraction = try PDFTextExtractor().extract(from: data)
        XCTAssertEqual(extraction.pageCount, 1)
    }
}
