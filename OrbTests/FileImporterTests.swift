import XCTest
@testable import Orb

final class FileImporterTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var importer: FileImporter!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-file-import-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        importer = FileImporter(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testImportCopiesBytesVerbatim() throws {
        let source = paths.root.appendingPathComponent("source.txt")
        let bytes = Data("hello orb".utf8)
        try bytes.write(to: source)
        let saved = try importer.importCopy(from: source)
        let blob = try BlobRepository(manager: manager).list(itemId: saved.id, kind: .original).first!
        let copied = try Data(contentsOf: URL(fileURLWithPath: blob.localPath))
        XCTAssertEqual(copied, bytes)
    }

    func testChecksumMatchesOriginal() throws {
        let source = paths.root.appendingPathComponent("checksum.md")
        let bytes = Data("# Doc".utf8)
        try bytes.write(to: source)
        let saved = try importer.importCopy(from: source)
        let blob = try BlobRepository(manager: manager).list(itemId: saved.id, kind: .original).first!
        XCTAssertEqual(blob.checksum, BlobRepository.checksum(for: bytes))
    }
}
