import Foundation

enum DrawerIconType: String, Codable, CaseIterable, Sendable {
    case sfSymbol
    case emoji
}

struct DrawerStyle: Equatable, Sendable {
    var icon: String
    var iconType: DrawerIconType
    var colorHex: String?

    static let defaultColor = "#6B7280"
}

struct DrawerStyleEditor: Sendable {
    let drawers: DrawerRepository

    func style(for drawer: Drawer) -> DrawerStyle {
        let icon = drawer.icon ?? "folder"
        let iconType: DrawerIconType = icon.count == 1 && icon.unicodeScalars.first?.properties.isEmojiPresentation == true ? .emoji : .sfSymbol
        return DrawerStyle(icon: icon, iconType: iconType, colorHex: drawer.color ?? DrawerStyle.defaultColor)
    }

    func apply(style: DrawerStyle, to drawer: Drawer) throws -> Drawer {
        var updated = drawer
        updated.icon = style.icon
        updated.color = normalizedHex(style.colorHex)
        return try drawers.update(updated)
    }

    func normalizedHex(_ value: String?) -> String? {
        guard var hex = value?.trimmingCharacters(in: .whitespacesAndNewlines), !hex.isEmpty else { return nil }
        if !hex.hasPrefix("#") { hex = "#\(hex)" }
        return hex.uppercased()
    }
}
