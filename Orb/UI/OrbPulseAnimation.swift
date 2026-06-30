import Foundation

struct OrbPulseAnimation: Sendable {
    private(set) var lastPulseAt: Date?
    let cooldown: TimeInterval

    init(cooldown: TimeInterval = 0.35) {
        self.cooldown = cooldown
    }

    mutating func shouldPulse(now: Date = Date()) -> Bool {
        if let lastPulseAt, now.timeIntervalSince(lastPulseAt) < cooldown {
            return false
        }
        lastPulseAt = now
        return true
    }

    func scale(forPulseTriggered: Bool) -> CGFloat {
        forPulseTriggered ? 1.12 : 1.0
    }
}
