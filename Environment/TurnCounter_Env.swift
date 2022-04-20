import SwiftUI

fileprivate struct TurnCounterKey: EnvironmentKey {
    static let defaultValue: TurnCounter = CalendarDailyTurnCounter.current(start: WordValidator.MAR_22_2022)
}

extension EnvironmentValues {
    var turnCounter: TurnCounter {
        get { self[TurnCounterKey.self] }
        set { self[TurnCounterKey.self] = newValue }
    }
}
