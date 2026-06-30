import Foundation

struct ErrorReport: Codable, Equatable, Sendable {
    var id: String
    var message: String
    var context: String?
    var createdAt: Date

    init(id: String = UUID().uuidString, message: String, context: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.message = message
        self.context = context
        self.createdAt = createdAt
    }
}

struct ErrorReporter: Sendable {
    let paths: StoragePaths

    private var logURL: URL {
        paths.logsURL.appendingPathComponent("errors.jsonl")
    }

    func report(_ error: Error, context: String? = nil) {
        let report = ErrorReport(message: error.localizedDescription, context: context)
        append(report)
        OrbLogger.shared.error("[\(context ?? "error")] \(error.localizedDescription)")
    }

    func report(message: String, context: String? = nil) {
        append(ErrorReport(message: message, context: context))
        OrbLogger.shared.error("[\(context ?? "error")] \(message)")
    }

    func recentReports(limit: Int = 50) -> [ErrorReport] {
        guard let data = try? String(contentsOf: logURL, encoding: .utf8) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return data
            .split(separator: "\n")
            .suffix(limit)
            .compactMap { line in
                guard let lineData = String(line).data(using: .utf8) else { return nil }
                return try? decoder.decode(ErrorReport.self, from: lineData)
            }
    }

    private func append(_ report: ErrorReport) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(report),
              let line = String(data: data, encoding: .utf8) else { return }
        let url = logURL
        try? FileManager.default.createDirectory(at: paths.logsURL, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        guard let handle = try? FileHandle(forWritingTo: url) else { return }
        defer { try? handle.close() }
        try? handle.seekToEnd()
        if let bytes = (line + "\n").data(using: .utf8) {
            try? handle.write(contentsOf: bytes)
        }
    }
}
