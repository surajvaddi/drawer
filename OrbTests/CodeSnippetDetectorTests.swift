import XCTest
@testable import Orb

final class CodeSnippetDetectorTests: XCTestCase {
    let detector = CodeSnippetDetector()

    func testDetectSwiftCodeBlock() {
        let code = "func greet() {\n  print(\"hi\")\n}"
        XCTAssertEqual(detector.detectLanguage(in: code), "swift")
    }

    func testDetectPythonFromKeywords() {
        let code = "def main():\n    print('hello')"
        XCTAssertEqual(detector.detectLanguage(in: code), "python")
    }
}
