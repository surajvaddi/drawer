import SwiftUI

struct SearchSettingsView: View {
    @Binding var settings: AppSettings

    var body: some View {
        Form {
            Toggle("Include OCR Text in Search", isOn: $settings.includeOCRInSearch)
            Toggle("Enter Pastes Instead of Copy", isOn: $settings.enterPastesInsteadOfCopy)
        }
    }
}
