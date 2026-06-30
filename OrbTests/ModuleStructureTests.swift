import XCTest

final class ModuleStructureTests: XCTestCase {
    private let moduleFolders = ["Core", "Storage", "Capture", "UI", "Search", "AI", "Services"]

    func testModuleFoldersExist() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let orbRoot = projectRoot.appendingPathComponent("Orb")
        for folder in moduleFolders {
            var isDirectory: ObjCBool = false
            let path = orbRoot.appendingPathComponent(folder).path
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue,
                "Missing module folder: \(folder)"
            )
        }
    }
}
