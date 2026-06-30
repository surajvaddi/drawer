import XCTest
@testable import Orb

final class FileDropPipelineIntegrationTests: XCTestCase {
    func testDropPDFOnOrbAppearsInInbox() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-drop-pdf-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(drawers: DrawerRepository(manager: manager), defaults: UserDefaults(suiteName: "orb.\(UUID().uuidString)")!).seedIfNeeded()
        let pdfURL = root.appendingPathComponent("drop.pdf")
        try TestFixtures.minimalPDFData().write(to: pdfURL)
        let pipeline = FileDropPipeline(coordinator: StorageCoordinator(paths: paths, manager: manager))
        let saved = try pipeline.importURLs([pdfURL]).first!
        XCTAssertEqual(saved.type, .pdf)
        XCTAssertTrue(try ItemRepository(manager: manager).listRecent().contains { $0.id == saved.id })
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
