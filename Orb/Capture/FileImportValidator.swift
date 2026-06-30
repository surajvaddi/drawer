import Foundation

struct FileImportValidation: Equatable, Sendable {
    var allowed: Bool
    var reason: String?
}

struct FileImportValidator: Sendable {
    let maxBytes: Int64
    let allowedExtensions: Set<String>

    init(maxBytes: Int64 = 50 * 1024 * 1024, allowedExtensions: Set<String> = ["pdf", "md", "markdown", "txt", "csv", "png", "jpg", "jpeg", "gif", "webp"]) {
        self.maxBytes = maxBytes
        self.allowedExtensions = allowedExtensions
    }

    func validate(url: URL) throws -> FileImportValidation {
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true else {
            return FileImportValidation(allowed: false, reason: "Not a regular file")
        }
        let ext = url.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else {
            return FileImportValidation(allowed: false, reason: "Unsupported extension")
        }
        if let size = values.fileSize, Int64(size) > maxBytes {
            return FileImportValidation(allowed: false, reason: "File exceeds size limit")
        }
        if let sniffed = sniffMIME(at: url), !isAllowedMIME(sniffed) {
            return FileImportValidation(allowed: false, reason: "MIME type not allowed")
        }
        return FileImportValidation(allowed: true, reason: nil)
    }

    private func sniffMIME(at url: URL) -> String? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        let prefix = handle.readData(ofLength: 16)
        if prefix.starts(with: [0x25, 0x50, 0x44, 0x46]) { return "application/pdf" }
        if prefix.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "image/png" }
        if prefix.starts(with: [0xFF, 0xD8, 0xFF]) { return "image/jpeg" }
        if let text = String(data: prefix, encoding: .utf8), text.allSatisfy({ $0.isASCII }) {
            return "text/plain"
        }
        return nil
    }

    private func isAllowedMIME(_ mime: String) -> Bool {
        mime.hasPrefix("text/") || mime == "application/pdf" || mime.hasPrefix("image/")
    }
}
