import XCTest
@testable import Orb

final class PrivateDrawerServiceTests: XCTestCase {
    private var manager: DatabaseManager!
    private var service: PrivateDrawerService!

    override func setUpWithError() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("orb-private-\(UUID().uuidString)", isDirectory: true)
        manager = DatabaseManager(paths: StoragePaths(root: root))
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
        service = PrivateDrawerService(drawers: DrawerRepository(manager: manager), isUnlocked: false)
    }

    override func tearDownWithError() throws { manager.close() }

    func testPrivateDrawerExcludedFromDefaultSearch() throws {
        let drawers = DrawerRepository(manager: manager)
        let drawer = try drawers.create(Drawer(name: "Secrets", isPrivate: true))
        XCTAssertFalse(service.includeInSearch(drawer: drawer))
    }

    func testEncryptionInterfacePluggable() throws {
        struct ReversingEncryptor: DrawerEncrypting {
            func encrypt(_ data: Data) throws -> Data { Data(data.reversed()) }
            func decrypt(_ data: Data) throws -> Data { Data(data.reversed()) }
        }
        let encryptor = ReversingEncryptor()
        let input = Data("secret".utf8)
        let encrypted = try encryptor.encrypt(input)
        XCTAssertEqual(try encryptor.decrypt(encrypted), input)
    }
}
