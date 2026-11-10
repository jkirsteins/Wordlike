import SwiftUI
import UserNotifications

/// Makes notifications show as banners (with sound) even while the app is open.
/// iOS suppresses them in the foreground unless the app opts in.
final class ReminderPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let options: UNNotificationPresentationOptions = [.banner, .sound]

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(Self.options)
    }
}

/// Schedules the evening "you haven't finished your word today"
/// local notifications.
///
/// One non-repeating notification is scheduled for each of the next
/// few days. Today's is skipped once the word is finished (won or lost),
/// so the user is still reminded on following days even if the app
/// is not opened.
enum DailyReminder {
    struct Time: Equatable {
        let hour: Int
        let minute: Int
    }

    static let idPrefix = "dailyReminder."

    /// Local times at which an unfinished word is reminded about each day.
    static let times = [Time(hour: 13, minute: 0), Time(hour: 22, minute: 30)]
    static let daysAhead = 7

    /// Kept alive here because `UNUserNotificationCenter` only holds its delegate weakly.
    static let presenter = ReminderPresenter()

    /// Call once at launch, before the app finishes starting.
    static func installForegroundPresentation() {
        UNUserNotificationCenter.current().delegate = presenter
    }

    /// Tests switch this off so they neither prompt for permission nor
    /// schedule real notifications.
    static var isEnabled = true

    /// Pure planner: when should reminders fire?
    static func fireDates(
        now: Date,
        calendar: Calendar,
        isTodayFinished: Bool,
        times: [Time] = DailyReminder.times,
        days: Int = DailyReminder.daysAhead
    ) -> [Date] {
        let startOfToday = calendar.startOfDay(for: now)

        return (0 ..< days).flatMap { offset -> [Date] in
            if offset == 0, isTodayFinished { return [] }

            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                return []
            }

            return times.compactMap { time -> Date? in
                guard let fire = calendar.date(
                    bySettingHour: time.hour,
                    minute: time.minute,
                    second: 0,
                    of: day
                ), fire > now
                else { return nil }

                return fire
            }
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
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return String(
            format: "%@%04d-%02d-%02d-%02d%02d",
            idPrefix,
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0,
            parts.hour ?? 0,
            parts.minute ?? 0
        )
    }

    /// Identifiers of all of today's reminders (whether or not they already fired).
    static func todaysIdentifiers(now: Date, calendar: Calendar, times: [Time] = DailyReminder.times) -> [String] {
        times.compactMap { time in
            calendar.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: now)
                .map { identifier(for: $0, calendar: calendar) }
        }
    }

    /// Asks for permission (the system prompts only the first time),
    /// then calls `completion` on the main queue regardless of the answer.
    static func requestAuthorization(completion: @escaping () -> Void) {
        guard isEnabled else {
            DispatchQueue.main.async(execute: completion)
            return
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// The notification itself: time sensitive (breaks through Focus) and
    /// badges the app icon until the word is finished.
    static func makeContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Bundle.main.displayName
        content.body = NSLocalizedString("Daily reminder body", comment: "")
        content.sound = .default
        content.badge = 1
        content.interruptionLevel = .timeSensitive
        return content
    }

    /// Reminds about the default language's word, whichever language is on screen.
    /// With no default chosen yet there is nothing to remind about.
    static func rescheduleForDefaultLanguage(turnCounter: TurnCounter) {
        guard let language = AppLanguage.storedDefault() else { return }
        let state = UserDefaults.standard.string(forKey: language.turnStateKey)
            .flatMap { DailyState(rawValue: $0) }
        reschedule(dailyState: state, turnCounter: turnCounter)
    }

    /// Replaces all pending reminders based on the current state.
    /// Does nothing if notifications are not allowed.
    static func reschedule(
        dailyState: DailyState?,
        turnCounter: TurnCounter,
        now: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) {
        guard isEnabled else { return }

        let finished = isTodayFinished(dailyState, turnCounter: turnCounter, now: now)
        let dates = fireDates(now: now, calendar: calendar, isTodayFinished: finished)
        let center = UNUserNotificationCenter.current()

        if finished {
            // Nothing left to remind about: drop the badge and any reminder still in the tray.
            center.setBadgeCount(0)
            center.removeDeliveredNotifications(
                withIdentifiers: todaysIdentifiers(now: now, calendar: calendar)
            )
        }

        center.getNotificationSettings { settings in
            let allowed = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
            guard allowed else { return }

            center.getPendingNotificationRequests { pending in
                let stale = pending.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
                center.removePendingNotificationRequests(withIdentifiers: stale)

                for date in dates {
                    let content = makeContent()

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
