import Foundation

struct CrashRecoveryService: Sendable {
    let paths: StoragePaths
    let manager: DatabaseManager

    private var markerURL: URL {
        paths.root.appendingPathComponent(".orb-recovery-marker")
    }

    func markSessionStart() throws {
        try "running".write(to: markerURL, atomically: true, encoding: .utf8)
    }

    func markSessionEnd() {
        try? FileManager.default.removeItem(at: markerURL)
    }

    func needsRecovery() -> Bool {
        FileManager.default.fileExists(atPath: markerURL.path)
    }

    func recover() throws {
        guard needsRecovery() else { return }
        try manager.exec("PRAGMA wal_checkpoint(FULL);")
        try markSessionStart()
    }
}
