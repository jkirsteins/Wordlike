import SwiftUI


/// Protocol for determining when a turn begins/ends,
/// and if subsequent periods can form a streak or not.
///
/// An implementation can be interval-based (e.g. 10 
/// seconds - useful for debugging, to test with 
/// short turns) or day-based (the actual game behaviour)
protocol TurnCounter
{
    /// Remaining time before next period
    func remainingTtl(at now: Date) -> TimeInterval
    
    /// For checking if two periods are streak-able
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool
    
    /// Is current period still fresh relative to given time
    func isFresh(_ stateRef: Date, at now: Date) -> Bool
    
    /// Which turn is this? Use it to find the word
    func turnIndex(at now: Date) -> Int
}
