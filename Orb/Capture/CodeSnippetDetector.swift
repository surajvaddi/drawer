import Foundation

struct CodeSnippetDetector: Sendable {
    func isCode(_ text: String) -> Bool {
        detectLanguage(in: text) != nil
    }

    func detectLanguage(in text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("func ") && trimmed.contains("{") && trimmed.contains("}") { return "swift" }
        if trimmed.contains("import Swift") || trimmed.contains("@main") { return "swift" }
        if trimmed.contains("def ") && trimmed.contains(":") { return "python" }
        if trimmed.contains("import os") || trimmed.contains("print(") { return "python" }
        if trimmed.contains("#include") || trimmed.contains("int main(") { return "c" }
        if trimmed.starts(with: "{") && trimmed.contains("\"language\"") { return "json" }
        let symbolCount = trimmed.filter { "{}();[]".contains($0) }.count
        if symbolCount >= 4 && trimmed.contains("\n") { return "code" }
        return nil
    }
}
