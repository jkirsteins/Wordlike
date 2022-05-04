/// Extensions useful for TurnCounter implementations.

import SwiftUI

extension Date {
    /* Use Calendar.current because
     we want to rollover at local-timezone midnight
     not UTC */
    func startOfNextDay(in cal: Calendar) -> Date {
        return cal.nextDate(
            after: self, 
            matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    
    func secondsUntilTheNextDay(in cal: Calendar) -> TimeInterval {
        return startOfNextDay(in: cal).timeIntervalSince(self) 
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
