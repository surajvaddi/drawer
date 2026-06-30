import AppKit

protocol PasteboardProviding: AnyObject {
    var changeCount: Int { get }
    var types: [NSPasteboard.PasteboardType]? { get }
    func string(forType type: NSPasteboard.PasteboardType) -> String?
    func data(forType type: NSPasteboard.PasteboardType) -> Data?
    func setString(_ string: String, forType type: NSPasteboard.PasteboardType)
    func setData(_ data: Data, forType type: NSPasteboard.PasteboardType)
    func clearContents()
}

extension NSPasteboard: PasteboardProviding {}
