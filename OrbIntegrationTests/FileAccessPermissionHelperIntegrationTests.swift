import XCTest
@testable import Orb

final class FileAccessPermissionHelperIntegrationTests: XCTestCase {
    func testReferenceImportAfterUserGrantsAccess() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ref-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let source = root.appendingPathComponent("ref.txt")
        try Data("reference".utf8).write(to: source)
        let helper = FileAccessPermissionHelper()
        let bookmark = try helper.createBookmark(for: source)
        let resolved = try helper.resolveBookmark(bookmark)
        let saved = try FileReferenceImporter(coordinator: StorageCoordinator(paths: paths, manager: manager)).importReference(from: resolved).item
        XCTAssertEqual(saved.type, .file)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
