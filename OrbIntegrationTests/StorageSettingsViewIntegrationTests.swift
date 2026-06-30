import XCTest
@testable import Orb

final class StorageSettingsViewIntegrationTests: XCTestCase {
    func testStorageSettingsAffectImporter() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-storage-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let source = root.appendingPathComponent("import.txt")
        try Data("storage".utf8).write(to: source)
        let pipeline = FileDropPipeline(coordinator: StorageCoordinator(paths: paths, manager: manager), useReferenceImport: false)
        let saved = try pipeline.importURLs([source]).first!
        XCTAssertEqual(saved.type, .file)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
