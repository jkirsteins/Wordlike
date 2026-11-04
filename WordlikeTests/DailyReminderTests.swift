import UserNotifications
@testable import Wordlike
import XCTest

final class DailyReminderTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Riga") ?? .current
        return c
    }

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) throws -> Date {
        try XCTUnwrap(cal.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min)))
    }

    func testMorningUnfinishedSchedulesTodayAndSixMore() throws {
        let now = try date(2026, 11, 1, 9, 0)
        let dates = DailyReminder.fireDates(now: now, calendar: cal, isTodayFinished: false)

        XCTAssertEqual(dates.count, 7)
        XCTAssertEqual(dates.first, try date(2026, 11, 1, 20, 0))
        XCTAssertEqual(dates.last, try date(2026, 11, 7, 20, 0))
    }

    func testAfterReminderTimeStartsTomorrow() throws {
        let now = try date(2026, 11, 1, 20, 30)
        let dates = DailyReminder.fireDates(now: now, calendar: cal, isTodayFinished: false)

        XCTAssertEqual(dates.count, 6)
        XCTAssertEqual(dates.first, try date(2026, 11, 2, 20, 0))
    }

    func testFinishedTodaySkipsToday() throws {
        let now = try date(2026, 11, 1, 9, 0)
        let dates = DailyReminder.fireDates(now: now, calendar: cal, isTodayFinished: true)

        XCTAssertEqual(dates.count, 6)
        XCTAssertEqual(dates.first, try date(2026, 11, 2, 20, 0))
    }

    func testStaysAtLocalTimeAcrossDstChange() throws {
        // Europe/Riga leaves summer time on 2026-10-25
        let now = try date(2026, 10, 23, 9, 0)
        let dates = DailyReminder.fireDates(now: now, calendar: cal, isTodayFinished: false)

        for fire in dates {
            let parts = cal.dateComponents([.hour, .minute], from: fire)
            XCTAssertEqual(parts.hour, 20)
            XCTAssertEqual(parts.minute, 0)
        }
    }

    func testIdentifierIsPerDay() throws {
        let id = try DailyReminder.identifier(for: date(2026, 11, 3, 20, 0), calendar: cal)
        XCTAssertEqual(id, "dailyReminder.2026-11-03")
    }

    func testIsTodayFinishedOnlyForFreshFinishedState() throws {
        let counter = CalendarDailyTurnCounter(start: WordValidator.MAR_22_2022, cal: cal)
        let word = WordModel("slota", locale: .lv_LV)
        let now = try date(2026, 11, 1, 12, 0)

        func state(on day: Date, _ s: DailyState.State) -> DailyState {
            DailyState(expected: word, date: day, rows: [], state: s)
        }

        let finishedToday = state(on: now, .finished(isTallied: true, isWon: false))
        let finishedYesterday = try state(on: date(2026, 10, 31, 12, 0), .finished(isTallied: true, isWon: true))
        let inProgress = state(on: now, .inProgress)

        XCTAssertTrue(DailyReminder.isTodayFinished(finishedToday, turnCounter: counter, now: now))
        XCTAssertFalse(DailyReminder.isTodayFinished(finishedYesterday, turnCounter: counter, now: now))
        XCTAssertFalse(DailyReminder.isTodayFinished(inProgress, turnCounter: counter, now: now))
        XCTAssertFalse(DailyReminder.isTodayFinished(nil, turnCounter: counter, now: now))
    }

    func testNotificationsAreShownWhileAppIsOpen() {
        DailyReminder.installForegroundPresentation()

        let center = UNUserNotificationCenter.current()
        XCTAssertTrue(center.delegate === DailyReminder.presenter)
        XCTAssertTrue(ReminderPresenter.options.contains(.banner))
        XCTAssertTrue(ReminderPresenter.options.contains(.sound))
    }
}
