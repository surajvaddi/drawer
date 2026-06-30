import Foundation

struct ZIPExportService: Sendable {
    let jsonExport: JSONExportService
    let markdownExport: MarkdownExportService
    let paths: StoragePaths

    func exportArchive(to destinationURL: URL) throws {
        let fm = FileManager.default
        let tempDir = paths.root.appendingPathComponent("export-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tempDir) }

        let jsonURL = tempDir.appendingPathComponent("orb-export.json")
        let markdownURL = tempDir.appendingPathComponent("orb-export.md")
        try jsonExport.export(to: jsonURL)
        try markdownExport.export(to: markdownURL)

        if fm.fileExists(atPath: destinationURL.path) {
            try fm.removeItem(at: destinationURL)
        }
        try fm.zipItem(at: tempDir, to: destinationURL)
    }
}

private extension FileManager {
    func zipItem(at sourceURL: URL, to destinationURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-c", "-k", "--sequesterRsrc", sourceURL.path, destinationURL.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw OrbError.storage("Failed to create ZIP archive")
        }
    }
}
