import XCTest
@testable import Orb

final class PasteboardReaderTests: XCTestCase {
    func testReadPlainText() {
        let mock = MockPasteboard()
        mock.setFixture(text: "hello world")
        let payload = PasteboardReader(pasteboard: mock).read()
        XCTAssertEqual(payload.text, "hello world")
    }

    func testReadFileURLList() {
        let mock = MockPasteboard()
        mock.setFixture(fileURL: "/tmp/test.pdf")
        let payload = PasteboardReader(pasteboard: mock).read()
        XCTAssertEqual(payload.fileURLs.first?.path, "/tmp/test.pdf")
    }

    func testReadPNGImageData() {
        let mock = MockPasteboard()
        let data = Data([0x89, 0x50, 0x4E, 0x47])
        mock.setFixture(png: data)
        let payload = PasteboardReader(pasteboard: mock).read()
        XCTAssertEqual(payload.imageData, data)
    }
}
