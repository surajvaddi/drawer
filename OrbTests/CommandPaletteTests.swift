import XCTest
@testable import Orb

final class CommandPaletteTests: XCTestCase {
    func testFilterCommandsByQuery() {
        let palette = CommandPalette()
        let filtered = palette.filter(query: "clip")
        XCTAssertTrue(filtered.contains { $0.id == "save_clipboard" })
        XCTAssertFalse(filtered.contains { $0.id == "new_drawer" })
    }

    func testExecuteSelectedCommand() {
        var executed = false
        let palette = CommandPalette(handlers: ["save_clipboard": { executed = true }])
        let command = CommandPaletteCommand(id: "save_clipboard", title: "Save Clipboard", keywords: [])
        palette.execute(command)
        XCTAssertTrue(executed)
    }
}
