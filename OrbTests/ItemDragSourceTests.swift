import XCTest
@testable import Orb

final class ItemDragSourceTests: XCTestCase {
    func testDragProvidesTextPayload() {
        let source = ItemDragSource()
        let payload = source.payload(for: Item(type: .text, title: "Note", contentText: "snippet"))
        XCTAssertEqual(payload.text, "snippet")
    }

    func testDragProvidesFileURLForDocuments() {
        let source = ItemDragSource()
        let path = "/tmp/report.pdf"
        let payload = source.payload(for: Item(type: .pdf, title: "Report", contentText: path))
        XCTAssertEqual(payload.fileURL, path)
    }
}
