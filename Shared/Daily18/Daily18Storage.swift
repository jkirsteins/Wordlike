import Foundation

/// Storage keys and the day counter for the 18 vardi mode.
enum Daily18Storage {
    static let stateKey = "daily18.lv"
    static let statsKey = "stats18.lv"

    /// 2026-07-17T00:00:00Z. Day 0 is puzzle #1.
    static let epoch = Date(timeIntervalSince1970: 1_784_246_400)

    static func makeTurnCounter() -> TurnCounter {
        CalendarDailyTurnCounter.current(start: epoch)
    }

    static func storedState() -> Daily18State? {
        guard let raw = UserDefaults.standard.string(forKey: stateKey) else {
            return nil
        }
        return Daily18State(rawValue: raw)
    }

    static func isFinishedToday(at now: Date = Date()) -> Bool {
        guard let state = storedState() else { return false }
        return state.phase == .finished
            && state.day == makeTurnCounter().turnIndex(at: now)
    }
}
