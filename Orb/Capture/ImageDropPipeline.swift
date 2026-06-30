import Foundation

struct ImageDropPipeline: Sendable {
    let screenshotPipeline: ScreenshotSavePipeline

    func importPNG(_ data: Data, title: String = "Dropped Image") throws -> Item {
        try screenshotPipeline.save(imageData: data, title: title, sourceApp: nil)
    }
}

struct TextDropPipeline: Sendable {
    let coordinator: StorageCoordinator

    func importText(_ text: String) async throws -> Item {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return try await LinkItemProcessor(coordinator: coordinator).process(urlString: trimmed)
        }
        return try TextItemProcessor(coordinator: coordinator).process(text: trimmed)
    }
}
