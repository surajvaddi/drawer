import XCTest
@testable import Orb

final class CrashRecoveryServiceIntegrationTests: XCTestCase {
    func testSimulatedCrashRecoveryRestoresConsistency() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-int-\(UUID().uuidString)", isDirectory: true)
        let paths = StoragePaths(root: root)
        let manager = DatabaseManager(paths: paths)
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        _ = try ItemRepository(manager: manager).create(Item(type: .text, title: "Crash", contentText: "data"))
        try service.recover()
        service.markSessionEnd()
        XCTAssertFalse(service.needsRecovery())
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }
}
