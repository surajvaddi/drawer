import SwiftUI

struct AISettingsView: View {
    @Binding var settings: AppSettings

    var body: some View {
        Form {
            Toggle("Enable AI Features", isOn: $settings.aiEnabled)
            Toggle("Local AI Only", isOn: $settings.aiLocalOnly)
                .disabled(!settings.aiEnabled)
            Toggle("Ask Before Cloud AI", isOn: $settings.aiAskBeforeCloud)
                .disabled(!settings.aiEnabled || settings.aiLocalOnly)
            if !settings.aiEnabled {
                Text("AI annotations, summaries, and semantic search are disabled.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
