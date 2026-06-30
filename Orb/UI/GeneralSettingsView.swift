import SwiftUI

struct GeneralSettingsView: View {
    @Binding var settings: AppSettings

    var body: some View {
        Form {
            Slider(value: $settings.orbDiameter, in: 32...72, step: 1) {
                Text("Orb Size")
            }
            Slider(value: $settings.orbOpacity, in: 0...1) {
                Text("Opacity")
            }
            Toggle("Edge Snap", isOn: $settings.edgeSnapEnabled)
            Toggle("Hide in Fullscreen Apps", isOn: $settings.hideInFullscreen)
        }
        .onChange(of: settings.orbOpacity) { _, newValue in
            settings.orbOpacity = min(1, max(0, newValue))
        }
    }
}
