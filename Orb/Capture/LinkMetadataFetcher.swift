import Foundation

struct LinkMetadata: Equatable, Sendable {
    var title: String?
    var faviconURL: URL?
}

protocol LinkMetadataFetching: Sendable {
    func fetchMetadata(for urlString: String) async throws -> LinkMetadata
}

struct LinkMetadataFetcher: LinkMetadataFetching {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchMetadata(for urlString: String) async throws -> LinkMetadata {
        guard let url = URL(string: urlString) else {
            throw OrbError.invalidData("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        let (data, _) = try await session.data(for: request)
        guard let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            return LinkMetadata(title: nil, faviconURL: faviconURL(for: url))
        }
        return LinkMetadata(title: parseTitle(from: html), faviconURL: faviconURL(for: url))
    }

    func parseTitle(from html: String) -> String? {
        let patterns = [
            #"<title[^>]*>(.*?)</title>"#,
            #"<meta[^>]+property=["']og:title["'][^>]+content=["'](.*?)["']"#,
            #"<meta[^>]+name=["']twitter:title["'][^>]+content=["'](.*?)["']"#
        ]
        for pattern in patterns {
            if let match = html.firstCaptureGroup(matching: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                let decoded = match
                    .replacingOccurrences(of: "&amp;", with: "&")
                    .replacingOccurrences(of: "&#39;", with: "'")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !decoded.isEmpty { return decoded }
            }
        }
        return nil
    }

    func faviconURL(for pageURL: URL) -> URL? {
        guard let host = pageURL.host else { return nil }
        var components = URLComponents()
        components.scheme = pageURL.scheme ?? "https"
        components.host = host
        components.path = "/favicon.ico"
        return components.url
    }
}

private extension String {
    func firstCaptureGroup(matching pattern: String, options: NSRegularExpression.Options = []) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let range = NSRange(startIndex..., in: self)
        guard let match = regex.firstMatch(in: self, options: [], range: range), match.numberOfRanges > 1 else {
            return nil
        }
        guard let swiftRange = Range(match.range(at: 1), in: self) else { return nil }
        return String(self[swiftRange])
    }
}
