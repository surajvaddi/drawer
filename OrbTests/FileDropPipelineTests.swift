import XCTest
@testable import Orb

final class FileDropPipelineTests: XCTestCase {
    private var paths: StoragePaths!
    private var manager: DatabaseManager!
    private var pipeline: FileDropPipeline!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-file-drop-\(UUID().uuidString)", isDirectory: true)
        paths = StoragePaths(root: root)
        manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        pipeline = FileDropPipeline(coordinator: StorageCoordinator(paths: paths, manager: manager))
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: paths.root)
    }

    func testDropSinglePDFImports() throws {
        let pdfURL = paths.root.appendingPathComponent("doc.pdf")
        try TestFixtures.minimalPDFData().write(to: pdfURL)
        let items = try pipeline.importURLs([pdfURL])
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.type, .pdf)
    }

    func testDropMultipleFilesCreatesMultipleItems() throws {
        let first = paths.root.appendingPathComponent("a.txt")
        let second = paths.root.appendingPathComponent("b.txt")
        try Data("one".utf8).write(to: first)
        try Data("two".utf8).write(to: second)
        let items = try pipeline.importURLs([first, second])
        XCTAssertEqual(items.count, 2)
    }
}
