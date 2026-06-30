import XCTest
@testable import Orb

final class PasteboardWriterTests: XCTestCase {
    func testWriteTextToPasteboard() throws {
        let mock = MockPasteboard()
        let writer = PasteboardWriter(pasteboard: mock)
        try writer.write(item: Item(type: .text, title: "T", contentText: "body"))
        XCTAssertEqual(mock.string(forType: .string), "body")
    }

    func testWriteImageToPasteboard() throws {
        let mock = MockPasteboard()
        let writer = PasteboardWriter(pasteboard: mock)
        let data = Data([1, 2, 3])
        try writer.write(item: Item(type: .screenshot, title: "S"), blobData: data)
        XCTAssertEqual(mock.data(forType: .png), data)
    }
}
