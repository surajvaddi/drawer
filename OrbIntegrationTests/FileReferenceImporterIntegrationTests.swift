import XCTest
@testable import Orb

final class FileReferenceImporterIntegrationTests: XCTestCase {
    func testReferenceImportSurvivesReopen() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-ref-reopen-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let source = root.appendingPathComponent("persist.txt")
        try Data("persist".utf8).write(to: source)
        let importer = FileReferenceImporter(coordinator: StorageCoordinator(paths: paths, manager: manager))
        let result = try importer.importReference(from: source)
        manager.close()
        let resolved = try importer.resolve(bookmark: result.bookmark)
        XCTAssertEqual(resolved.lastPathComponent, "persist.txt")
        try? FileManager.default.removeItem(at: root)
    }
}
