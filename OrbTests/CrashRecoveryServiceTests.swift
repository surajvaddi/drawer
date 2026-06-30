import XCTest
@testable import Orb

final class CrashRecoveryServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-test-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }

    override func tearDownWithError() throws {
        manager.close()
        try? FileManager.default.removeItem(at: root)
    }

    func testRecoverPendingCaptureEvent() throws {
        let paths = StoragePaths(root: root)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        XCTAssertTrue(service.needsRecovery())
        try service.recover()
        XCTAssertTrue(service.needsRecovery())
    }

    func testDeleteOrphanBlobsWithoutDBRows() throws {
        let paths = StoragePaths(root: root)
        let service = CrashRecoveryService(paths: paths, manager: manager)
        try service.markSessionStart()
        try service.recover()
        service.markSessionEnd()
        XCTAssertFalse(service.needsRecovery())
    }
}
