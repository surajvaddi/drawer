import XCTest
@testable import Orb

final class FileImporterIntegrationTests: XCTestCase {
    func testDropFileOnOrbImportsCopy() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drop-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let source = root.appendingPathComponent("drop.txt")
        try Data("dropped".utf8).write(to: source)
        let saved = try FileImporter(coordinator: StorageCoordinator(paths: paths, manager: manager)).importCopy(from: source)
        XCTAssertEqual(saved.type, .file)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
