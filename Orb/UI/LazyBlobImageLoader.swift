import AppKit
import Foundation

actor LazyBlobImageLoader {
    private var cache: [String: NSImage] = [:]

    func load(path: String) -> NSImage? {
        if let cached = cache[path] { return cached }
        guard FileManager.default.fileExists(atPath: path),
              let image = NSImage(contentsOfFile: path) else { return nil }
        cache[path] = image
        return image
    }

    func evict(path: String) {
        cache.removeValue(forKey: path)
    }

    func clear() {
        cache.removeAll()
    }
}
