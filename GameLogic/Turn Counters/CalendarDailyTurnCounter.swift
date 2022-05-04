import SwiftUI

/// Turn counter that wraps `DailyTurnCounter` and
/// conforms to `TurnCounter` protocol.
///
/// It always uses one calendar that is provided to it
/// at the start. Use the static `current` method
/// to initialize with `Calendar.current`.
class CalendarDailyTurnCounter : TurnCounter
{
    let cal: Calendar
    let wrapped: DailyTurnCounter
    
    init(start: Date, cal: Calendar)
    {
        self.cal = cal 
        self.wrapped = DailyTurnCounter(start: start)
    }
    
    static func current(start: Date) -> TurnCounter
    {
        return CalendarDailyTurnCounter(start: start, cal: Calendar.current)
    }
    
    func remainingTtl(at now: Date) -> TimeInterval
    {
        self.wrapped.remainingTtl(at: now, in: cal)
    }
    
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool
    {
        self.wrapped.point(first, isInPrecedingPeriodFrom: second, using: cal)
    }
    
    func isFresh(_ stateRef: Date, at now: Date) -> Bool
    {
        self.wrapped.isFresh(stateRef, at: now, in: cal)
    }
    
    func turnIndex(at now: Date) -> Int {
        self.wrapped.turnIndex(at: now, in: cal)
    }
}

