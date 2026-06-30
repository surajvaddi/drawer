import XCTest
@testable import Orb

final class FileReferenceImporterTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var importer: FileReferenceImporter!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-file-ref-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        importer = FileReferenceImporter(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testBookmarkResolveAfterImport() throws {
        let source = paths.root.appendingPathComponent("reference.txt")
        try Data("ref".utf8).write(to: source)
        let result = try importer.importReference(from: source)
        let resolved = try importer.resolve(bookmark: result.bookmark)
        XCTAssertEqual(resolved.path, source.path)
    }

    func testReferenceDoesNotDuplicateBytes() throws {
        let source = paths.root.appendingPathComponent("reference.md")
        try Data("# Ref".utf8).write(to: source)
        let result = try importer.importReference(from: source)
        let blobs = try BlobRepository(manager: manager).list(itemId: result.item.id)
        XCTAssertTrue(blobs.isEmpty)
    }
}
