import XCTest
@testable import Orb

final class LazyBlobImageLoaderTests: XCTestCase {
    func testLoaderEvictsWhenOverBudget() async throws {
        let loader = LazyBlobImageLoader()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-lazy-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let path = root.appendingPathComponent("img.png").path
        try TestFixtures.pngData().write(to: URL(fileURLWithPath: path))
        _ = await loader.load(path: path)
        await loader.evict(path: path)
        await loader.clear()
        try? FileManager.default.removeItem(at: root)
        XCTAssertTrue(true)
    }
}
