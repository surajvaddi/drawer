import XCTest
@testable import Orb

final class LazyBlobImageLoaderTests: XCTestCase {
    func testLoaderEvictsWhenOverBudget() async throws {
        let loader = LazyBlobImageLoader()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-lazy-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let path = root.appendingPathComponent("img.png").path
        try TestFixtures.pngData().write(to: URL(fileURLWithPath: path))
        let loaded = await loader.load(path: path)
        XCTAssertNotNil(loaded)
        await loader.evict(path: path)
        let reloaded = await loader.load(path: path)
        XCTAssertNotNil(reloaded)
        await loader.clear()
        let missing = await loader.load(path: root.appendingPathComponent("missing.png").path)
        XCTAssertNil(missing)
        try? FileManager.default.removeItem(at: root)
    }
}
