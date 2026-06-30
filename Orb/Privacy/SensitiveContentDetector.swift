import Foundation

enum SensitiveFinding: String, Equatable, Sendable {
    case awsAccessKey
    case creditCard
    case privateKey
    case ssn
}

struct SensitiveContentDetector: Sendable {
    func detect(in text: String) -> [SensitiveFinding] {
        var findings: [SensitiveFinding] = []
        if text.range(of: #"AKIA[0-9A-Z]{16}"#, options: .regularExpression) != nil {
            findings.append(.awsAccessKey)
        }
        if detectCreditCard(in: text) {
            findings.append(.creditCard)
        }
        if text.contains("BEGIN PRIVATE KEY") || text.contains("BEGIN RSA PRIVATE KEY") {
            findings.append(.privateKey)
        }
        if text.range(of: #"\b\d{3}-\d{2}-\d{4}\b"#, options: .regularExpression) != nil {
            findings.append(.ssn)
        }
        return findings
    }

    private func detectCreditCard(in text: String) -> Bool {
        let numbers = text.filter(\.isNumber)
        guard numbers.count >= 13 else { return false }
        for length in 13...19 where numbers.count >= length {
            for start in 0...(numbers.count - length) {
                let startIndex = numbers.index(numbers.startIndex, offsetBy: start)
                let endIndex = numbers.index(startIndex, offsetBy: length)
                if luhnValid(String(numbers[startIndex..<endIndex])) { return true }
            }
        }
        return false
    }

    private func luhnValid(_ number: String) -> Bool {
        guard number.count >= 13 else { return false }
        var sum = 0
        let reversed = number.reversed().map { Int(String($0)) ?? 0 }
        for (index, digit) in reversed.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
