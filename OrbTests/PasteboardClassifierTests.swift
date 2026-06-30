import XCTest
@testable import Orb

final class PasteboardClassifierTests: XCTestCase {
    let classifier = PasteboardClassifier()

    func testClassifyPlainText() {
        let types = classifier.classify(types: [.string])
        XCTAssertTrue(types.contains(.text))
    }

    func testClassifyURL() {
        let primary = classifier.primaryType(from: [.string], text: "https://example.com")
        XCTAssertEqual(primary, .url)
    }

    func testClassifyImage() {
        let types = classifier.classify(types: [.png])
        XCTAssertTrue(types.contains(.image))
    }

    func testClassifyMultipleFiles() {
        let types = classifier.classify(types: [.fileURL])
        XCTAssertEqual(classifier.primaryType(from: [.fileURL], text: nil), .file)
        XCTAssertTrue(types.contains(.file))
    }
}

import AppKit
