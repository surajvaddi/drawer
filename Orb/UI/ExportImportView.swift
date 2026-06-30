import SwiftUI
import UniformTypeIdentifiers

struct ExportImportView: View {
    var onExportJSON: () throws -> Void
    var onExportMarkdown: () throws -> Void
    var onExportZIP: () throws -> Void
    var onImportJSON: (URL) throws -> Void
    var onImportMarkdown: (URL) throws -> Void
    @State private var statusMessage: String?
    @State private var showJSONImporter = false
    @State private var showMarkdownImporter = false

    var body: some View {
        Form {
            Section("Export") {
                Button("Export JSON") { run { try onExportJSON() } }
                Button("Export Markdown") { run { try onExportMarkdown() } }
                Button("Export ZIP Archive") { run { try onExportZIP() } }
            }
            Section("Import") {
                Button("Import JSON") { showJSONImporter = true }
                Button("Import Markdown") { showMarkdownImporter = true }
            }
            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .fileImporter(isPresented: $showJSONImporter, allowedContentTypes: [.json]) { result in
            importFile(result, handler: onImportJSON)
        }
        .fileImporter(isPresented: $showMarkdownImporter, allowedContentTypes: [.plainText]) { result in
            importFile(result, handler: onImportMarkdown)
        }
    }

    private func run(_ action: () throws -> Void) {
        do {
            try action()
            statusMessage = "Done"
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func importFile(_ result: Result<URL, Error>, handler: (URL) throws -> Void) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else {
                statusMessage = "Unable to access selected file"
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            try handler(url)
            statusMessage = "Import complete"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
