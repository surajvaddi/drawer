import XCTest
@testable import Orb

final class StorageSettingsViewTests: XCTestCase {
    func testImportVsReferenceDefault() {
        var settings = AppSettings()
        settings.importCopiesFiles = false
        XCTAssertFalse(settings.importCopiesFiles)
    }

    func testCacheSizeLimitEvictsThumbnails() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-cache-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        try paths.ensureDirectoriesExist()
        let thumbDir = paths.blobDirectory(for: .thumbnail)
        for index in 0..<3 {
            try Data(repeating: UInt8(index), count: 1024).write(to: thumbDir.appendingPathComponent("t\(index).bin"))
        }
        try ThumbnailCacheEvictor(paths: paths, maxBytes: 2048).evictIfNeeded()
        let remaining = try FileManager.default.contentsOfDirectory(at: thumbDir, includingPropertiesForKeys: nil)
        XCTAssertLessThan(remaining.count, 3)
        try? FileManager.default.removeItem(at: root)
    }
}
