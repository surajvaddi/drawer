import XCTest
@testable import Orb

final class SensitiveContentDetectorTests: XCTestCase {
    private let detector = SensitiveContentDetector()

    func testDetectAWSKeyPattern() {
        let findings = detector.detect(in: "key=AKIAIOSFODNN7EXAMPLE")
        XCTAssertTrue(findings.contains(.awsAccessKey))
    }

    func testDetectCreditCardNumber() {
        let findings = detector.detect(in: "card 4111111111111111")
        XCTAssertTrue(findings.contains(.creditCard))
    }

    func testDetectPrivateKeyBlock() {
        let findings = detector.detect(in: "-----BEGIN PRIVATE KEY-----\nMIIE")
        XCTAssertTrue(findings.contains(.privateKey))
    }

    func testNoFalsePositiveOnNormalText() {
        let findings = detector.detect(in: "Meeting notes for Tuesday standup")
        XCTAssertTrue(findings.isEmpty)
    }
}
