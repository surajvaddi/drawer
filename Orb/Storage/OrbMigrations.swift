import Foundation

enum OrbMigrations {
    static let all: [any DatabaseMigration] = [
        MigrationV1(),
        MigrationV2(),
        MigrationV3(),
        MigrationV4()
    ]
}
