import XCTest
@testable import Orb

final class DocumentItemActionsTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var coordinator: StorageCoordinator!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-doc-actions-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        coordinator = StorageCoordinator(paths: paths, manager: manager)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testRevealInFinderUsesNSURL() throws {
        let source = paths.root.appendingPathComponent("doc.txt")
        try Data("doc".utf8).write(to: source)
        let saved = try FileImporter(coordinator: coordinator).importCopy(from: source)
        let opener = MockWorkspaceOpener()
        let actions = DocumentItemActions(
            pasteboard: MockPasteboard(),
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager),
            workspace: opener
        )
        try actions.revealInFinder(item: saved)
        XCTAssertFalse(opener.openedURLs.isEmpty)
    }

    func testCopyFileWritesToPasteboard() throws {
        let source = paths.root.appendingPathComponent("copy.txt")
        let bytes = Data("copy me".utf8)
        try bytes.write(to: source)
        let saved = try FileImporter(coordinator: coordinator).importCopy(from: source)
        let pasteboard = MockPasteboard()
        let actions = DocumentItemActions(
            pasteboard: pasteboard,
            blobStore: coordinator.blobStore,
            blobs: BlobRepository(manager: manager)
        )
        try actions.copyFile(item: saved)
        XCTAssertNotNil(pasteboard.data(forType: .fileURL))
    }
}
