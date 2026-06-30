import Foundation
import PDFKit

struct PDFTextExtraction: Equatable, Sendable {
    var text: String
    var pageCount: Int
}

struct PDFTextExtractor: Sendable {
    func extract(from data: Data) throws -> PDFTextExtraction {
        guard let document = PDFDocument(data: data) else {
            throw OrbError.invalidData("Invalid PDF data")
        }
        var parts: [String] = []
        for index in 0..<document.pageCount {
            if let page = document.page(at: index), let text = page.string?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                parts.append(text)
            }
        }
        return PDFTextExtraction(text: parts.joined(separator: "\n\n"), pageCount: document.pageCount)
    }
}
