import SwiftUI

extension Date {
    /// Returns the start of the next day (midnight) in the given calendar.
    func startOfNextDay(in cal: Calendar) -> Date {
        cal.nextDate(
            after: self,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTimePreservingSmallerComponents
        )!
    }

    func secondsUntilTheNextDay(in cal: Calendar) -> TimeInterval {
        startOfNextDay(in: cal).timeIntervalSince(self)
    }
}

extension Calendar {
    static var gregorianUtc: Calendar {
        Calendar.gregorian(withHourOffsetFromUtc: 0)
    }

    static func gregorian(withHourOffsetFromUtc h: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: h * 3600)!
        return calendar
    }
}
