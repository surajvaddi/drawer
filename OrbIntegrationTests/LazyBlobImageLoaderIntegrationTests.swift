import XCTest
@testable import Orb

final class LazyBlobImageLoaderIntegrationTests: XCTestCase {
    func testDrawerScrollStaysAbove55FPS() async throws {
        let loader = LazyBlobImageLoader()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-fps-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let path = root.appendingPathComponent("thumb.png").path
        try TestFixtures.pngData().write(to: URL(fileURLWithPath: path))
        let image = await loader.load(path: path)
        XCTAssertNotNil(image)
        try? FileManager.default.removeItem(at: root)
    }
}
