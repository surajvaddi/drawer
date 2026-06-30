import XCTest
import UniformTypeIdentifiers
@testable import Orb

final class OrbDropTargetTests: XCTestCase {
    func testAcceptsRegisteredUTTypes() {
        let target = OrbDropTarget()
        let types = [UTType.plainText.identifier, UTType.png.identifier, UTType.pdf.identifier]
        XCTAssertTrue(target.accepts(types))
    }

    func testRejectUnsupportedTypes() {
        let target = OrbDropTarget()
        XCTAssertTrue(target.rejectsUnsupported([UTType.movie.identifier]))
    }
}
