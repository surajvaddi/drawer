import Foundation

struct URLNormalizer: Sendable {
    static func isURL(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let scheme = url.scheme, let host = url.host else {
            return false
        }
        return ["http", "https"].contains(scheme.lowercased()) && !host.isEmpty
    }

    static func normalize(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed) else { return trimmed }
        let trackingParams: Set<String> = ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "fbclid", "gclid"]
        components.queryItems = components.queryItems?.filter { !trackingParams.contains($0.name.lowercased()) }
        if components.queryItems?.isEmpty == true { components.queryItems = nil }
        return components.string ?? trimmed
    }

    static func domain(from urlString: String) -> String? {
        URL(string: urlString).flatMap { $0.host?.lowercased() }
    }
}
