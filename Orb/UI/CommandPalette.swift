import Foundation

struct CommandPaletteCommand: Identifiable, Equatable, Sendable {
    var id: String
    var title: String
    var keywords: [String]
}

struct CommandPalette: Sendable {
    let commands: [CommandPaletteCommand]
    var handlers: [String: () -> Void]

    init(commands: [CommandPaletteCommand] = CommandPalette.defaultCommands, handlers: [String: () -> Void] = [:]) {
        self.commands = commands
        self.handlers = handlers
    }

    static var defaultCommands: [CommandPaletteCommand] {
        [
            CommandPaletteCommand(id: "save_clipboard", title: "Save Clipboard", keywords: ["clipboard", "save"]),
            CommandPaletteCommand(id: "new_drawer", title: "New Drawer", keywords: ["drawer", "create"]),
            CommandPaletteCommand(id: "screenshot", title: "Capture Screenshot", keywords: ["screenshot", "capture"]),
            CommandPaletteCommand(id: "toggle_private", title: "Toggle Private Mode", keywords: ["private", "pause"])
        ]
    }

    func filter(query: String) -> [CommandPaletteCommand] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return commands }
        return commands.filter {
            $0.title.lowercased().contains(q) || $0.keywords.contains(where: { $0.contains(q) })
        }
    }

    func execute(_ command: CommandPaletteCommand) {
        handlers[command.id]?()
    }
}
