import Foundation
import os.log

enum OrbLogCategory: String {
    case general
    case storage
    case capture
    case search
    case ai
}

final class OrbLogger {
    static let shared = OrbLogger()

    private let subsystem = Bundle.main.bundleIdentifier ?? "dev.drawer.Orb"

    private init() {}

    func info(_ message: String, category: OrbLogCategory = .general) {
        log(message, type: .info, category: category)
    }

    func error(_ message: String, category: OrbLogCategory = .general) {
        log(message, type: .error, category: category)
    }

    func debug(_ message: String, category: OrbLogCategory = .general) {
        log(message, type: .debug, category: category)
    }

    func formattedMessage(_ message: String, category: OrbLogCategory) -> String {
        "[\(category.rawValue)] \(message)"
    }

    private func log(_ message: String, type: OSLogType, category: OrbLogCategory) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        let formatted = formattedMessage(message, category: category)
        logger.log(level: type, "\(formatted, privacy: .public)")
    }
}
