import Foundation

struct FTSQueryBuilder: Sendable {
    func build(from userInput: String, prefix: Bool = true) -> String {
        let tokens = escape(userInput)
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty else { return "" }
        if prefix {
            return tokens.map { "\($0)*" }.joined(separator: " ")
        }
        return tokens.joined(separator: " ")
    }

    func escape(_ input: String) -> String {
        var output = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let specials = CharacterSet(charactersIn: "\"':*-")
        output = String(output.unicodeScalars.map { specials.contains($0) ? " " : Character($0) })
        return output.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
