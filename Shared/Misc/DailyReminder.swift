import SwiftUI
import UserNotifications

/// Schedules the evening "you haven't finished your word today"
/// local notifications.
///
/// One non-repeating notification is scheduled for each of the next
/// few days. Today's is skipped once the word is finished (won or lost),
/// so the user is still reminded on following days even if the app
/// is not opened.
enum DailyReminder {
    static let idPrefix = "dailyReminder."
    static let hour = 20
    static let minute = 0
    static let daysAhead = 7

    /// Pure planner: when should reminders fire?
    static func fireDates(
        now: Date,
        calendar: Calendar,
        isTodayFinished: Bool,
        hour: Int = DailyReminder.hour,
        minute: Int = DailyReminder.minute,
        days: Int = DailyReminder.daysAhead
    ) -> [Date] {
        let startOfToday = calendar.startOfDay(for: now)

        return (0 ..< days).compactMap { offset -> Date? in
            if offset == 0, isTodayFinished { return nil }

            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday),
                  let fire = calendar.date(
                      bySettingHour: hour,
                      minute: minute,
                      second: 0,
                      of: day
                  ),
                  fire > now
            else { return nil }

            return fire
        }
    }

    /// Is the saved state for the current turn finished?
    static func isTodayFinished(_ state: DailyState?, turnCounter: TurnCounter, now: Date) -> Bool {
        guard let state = state, turnCounter.isFresh(state.date, at: now) else {
            return false
        }

        if case .finished = state.state { return true }
        return state.isFinished
    }

    static func identifier(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%@%04d-%02d-%02d",
            idPrefix,
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0
        )
    }

    /// Asks for permission (the system prompts only the first time),
    /// then calls `completion` on the main queue regardless of the answer.
    static func requestAuthorization(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// Replaces all pending reminders based on the current state.
    /// Does nothing if notifications are not allowed.
    static func reschedule(
        dailyState: DailyState?,
        turnCounter: TurnCounter,
        now: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let finished = isTodayFinished(dailyState, turnCounter: turnCounter, now: now)
        let dates = fireDates(now: now, calendar: calendar, isTodayFinished: finished)
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            let allowed = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
            guard allowed else { return }

            center.getPendingNotificationRequests { pending in
                let stale = pending.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
                center.removePendingNotificationRequests(withIdentifiers: stale)

                for date in dates {
                    let content = UNMutableNotificationContent()
                    content.title = Bundle.main.displayName
                    content.body = NSLocalizedString("Daily reminder body", comment: "")
                    content.sound = .default

                    let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: identifier(for: date, calendar: calendar),
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                }
            }
        }
    }
}
