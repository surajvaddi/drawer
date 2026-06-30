import XCTest
@testable import Orb

final class FileAccessPermissionHelperTests: XCTestCase {
    func testBookmarkCreatedOnUserSelection() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-bookmark-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let file = root.appendingPathComponent("grant.txt")
        try Data("grant".utf8).write(to: file)
        let helper = FileAccessPermissionHelper()
        let bookmark = try helper.createBookmark(for: file)
        XCTAssertFalse(bookmark.isEmpty)
        let resolved = try helper.resolveBookmark(bookmark)
        XCTAssertEqual(resolved.standardizedFileURL, file.standardizedFileURL)
        try? FileManager.default.removeItem(at: root)
    }
}
