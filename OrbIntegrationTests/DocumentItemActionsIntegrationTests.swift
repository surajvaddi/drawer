import XCTest
@testable import Orb

final class DocumentItemActionsIntegrationTests: XCTestCase {
    func testOpenDocumentInDefaultApp() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-open-doc-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let coordinator = StorageCoordinator(paths: paths, manager: manager)
        let source = root.appendingPathComponent("open.txt")
        try Data("open".utf8).write(to: source)
        let saved = try FileImporter(coordinator: coordinator).importCopy(from: source)
        let opener = MockWorkspaceOpener()
        try DocumentItemActions(
            pasteboard: MockPasteboard(),
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager),
            workspace: opener
        ).open(item: saved)
        XCTAssertEqual(opener.openedURLs.count, 1)
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
