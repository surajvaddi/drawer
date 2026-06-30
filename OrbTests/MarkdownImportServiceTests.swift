import XCTest
@testable import Orb

final class MarkdownImportServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        _ = try DefaultDataSeeder(
            drawers: DrawerRepository(manager: manager),
            defaults: UserDefaults(suiteName: "orb.md-import.\(UUID().uuidString)")!
        ).seedIfNeeded()
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testImportMarkdownCreatesTextItems() throws {
        let items = ItemRepository(manager: manager)
        let md = """
        # Orb Export

        ## First Note

        Body of first note

        ## Second Note

        Body of second note
        """
        let imported = try MarkdownImportService(items: items).importMarkdown(md)
        XCTAssertGreaterThanOrEqual(imported.count, 2)
        XCTAssertTrue(imported.allSatisfy { $0.type == .text })
    }

    func testImportBookmarksCreatesLinkItems() throws {
        let items = ItemRepository(manager: manager)
        let html = """
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <DT><A HREF="https://example.com">Example</A>
        <DT><A HREF="https://orb.dev">Orb</A>
        """
        let link = try items.create(Item(type: .url, title: "Example", contentText: "bookmark", sourceURL: "https://example.com"))
        XCTAssertEqual(link.type, .url)
        XCTAssertNotNil(link.sourceURL)
    }
}
