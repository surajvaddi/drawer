import SwiftUI

struct CaptureSettingsView: View {
    @Binding var settings: AppSettings
    var drawers: [Drawer]

    var body: some View {
        Form {
            Toggle("Clipboard Pulse", isOn: $settings.clipboardPulseEnabled)
            Toggle("Auto-save Clipboard", isOn: $settings.autoSaveClipboard)
            Picker("Default Drawer", selection: $settings.defaultDrawerID) {
                ForEach(drawers) { drawer in
                    Text(drawer.name).tag(drawer.id)
                }
            }
        }
    }
}
