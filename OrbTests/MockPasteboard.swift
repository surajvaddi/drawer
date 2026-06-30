import AppKit
@testable import Orb

final class MockPasteboard: PasteboardProviding {
    var changeCount: Int = 0
    var types: [NSPasteboard.PasteboardType]?
    private var strings: [NSPasteboard.PasteboardType: String] = [:]
    private var dataValues: [NSPasteboard.PasteboardType: Data] = [:]
    var fileURLs: [URL] = []

    func bumpChangeCount() {
        changeCount += 1
    }

    func string(forType type: NSPasteboard.PasteboardType) -> String? {
        strings[type]
    }

    func data(forType type: NSPasteboard.PasteboardType) -> Data? {
        dataValues[type]
    }

    @discardableResult
    func setString(_ string: String, forType type: NSPasteboard.PasteboardType) -> Bool {
        strings[type] = string
        types = Array(Set((types ?? []) + [type]))
        bumpChangeCount()
        return true
    }

    @discardableResult
    func setData(_ data: Data?, forType type: NSPasteboard.PasteboardType) -> Bool {
        guard let data else { return false }
        dataValues[type] = data
        types = Array(Set((types ?? []) + [type]))
        bumpChangeCount()
        return true
    }

    @discardableResult
    func clearContents() -> Int {
        let count = strings.count + dataValues.count
        strings.removeAll()
        dataValues.removeAll()
        fileURLs.removeAll()
        types = []
        bumpChangeCount()
        return count
    }

    func setFixture(text: String? = nil, url: String? = nil, png: Data? = nil, fileURL: String? = nil) {
        clearContents()
        var pasteTypes: [NSPasteboard.PasteboardType] = []
        if let text {
            strings[.string] = text
            pasteTypes.append(.string)
        }
        if let url {
            strings[.URL] = url
            pasteTypes.append(.URL)
        }
        if let png {
            dataValues[.png] = png
            pasteTypes.append(.png)
        }
        if let fileURL {
            strings[.fileURL] = fileURL
            fileURLs = [URL(fileURLWithPath: fileURL)]
            pasteTypes.append(.fileURL)
        }
        types = pasteTypes
        bumpChangeCount()
    }
}
