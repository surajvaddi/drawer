import Foundation

struct DataWiper: Sendable {
    let paths: StoragePaths
    let manager: DatabaseManager

    func deleteAll() throws {
        manager.close()
        try FileManager.default.removeItem(at: paths.root)
        try paths.ensureDirectoriesExist()
        try manager.open()
        try manager.migrate(using: OrbMigrations.all)
    }
}
