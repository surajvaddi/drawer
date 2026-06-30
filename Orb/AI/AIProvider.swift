import Foundation

protocol AIProvider: Sendable {
    var modelName: String { get }
    func generateTitle(from text: String) async throws -> String
    func generateSummary(from text: String) async throws -> String
    func generateTags(from text: String) async throws -> [String]
    func extractFacts(from text: String) async throws -> [String]
    func embed(text: String) async throws -> [Double]
}

struct MockAIProvider: AIProvider {
    let modelName = "mock-orb-v1"

    func generateTitle(from text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Untitled" }
        let words = trimmed.split(separator: " ").prefix(6)
        return words.joined(separator: " ")
    }

    func generateSummary(from text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > 120 else { return trimmed }
        let index = trimmed.index(trimmed.startIndex, offsetBy: 120)
        return String(trimmed[..<index]) + "…"
    }

    func generateTags(from text: String) async throws -> [String] {
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 4 }
        let sorted = Array(Set(words)).sorted()
        return Array(sorted[..<min(5, sorted.count)])
    }

    func extractFacts(from text: String) async throws -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 20 }
        return Array(lines[..<min(3, lines.count)])
    }

    func embed(text: String) async throws -> [Double] {
        let hash = text.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }
        return (0..<8).map { i in
            Double((hash &+ i * 997) % 1000) / 1000.0
        }
    }
}
