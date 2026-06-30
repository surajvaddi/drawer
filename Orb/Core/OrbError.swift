import Foundation

enum OrbError: Error, LocalizedError, Equatable {
    case storage(String)
    case capture(String)
    case search(String)
    case permissionDenied(String)
    case invalidData(String)
    case notFound(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .storage(let message),
             .capture(let message),
             .search(let message),
             .permissionDenied(let message),
             .invalidData(let message),
             .notFound(let message),
             .unknown(let message):
            return message
        }
    }
}
