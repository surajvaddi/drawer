import Foundation

struct DocumentTextExtractor: Sendable {
    func extract(from url: URL) throws -> String {
        let ext = url.pathExtension.lowercased()
        let data = try Data(contentsOf: url)
        switch ext {
        case "md", "markdown", "txt", "csv":
            guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                throw OrbError.invalidData("Unable to decode document text")
            }
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        case "pdf":
            return try PDFTextExtractor().extract(from: data).text
        default:
            throw OrbError.invalidData("Unsupported document type")
        }
    }
}
