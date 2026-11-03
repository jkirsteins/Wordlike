import SwiftUI
import UIKit
@testable import Wordlike
import XCTest

/// Turn counter whose "midnight" is controlled by the test.
private final class ManualTurnCounter: TurnCounter {
    var dayStart: Date

    init(dayStart: Date) {
        self.dayStart = dayStart
    }

    func remainingTtl(at now: Date) -> TimeInterval {
        3600
    }

    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool {
        true
    }

    func isFresh(_ stateRef: Date, at now: Date) -> Bool {
        stateRef >= dayStart
    }

    func turnIndex(at now: Date) -> Int {
        0
    }
}

/// Regression tests for the app being open (in memory) when a new day starts.
///
/// Once the app opens straight into the game there is no menu step that
/// rebuilds the game screen, so the screen itself must reset at midnight.
@MainActor
final class DayRolloverTests: XCTestCase {
    private func waitUntil(timeout: TimeInterval, _ condition: () -> Bool) -> Bool {
        let end = Date().addingTimeInterval(timeout)
        while Date() < end {
            if condition() { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return condition()
    }

    /// Number of green/yellow pixels in the board and keyboard area (below the
    /// navigation bar, whose logo tiles are randomly colored). A finished board
    /// and its keyboard hints are full of them; a brand new empty game has none.
    /// (The blue "enter" key and grey tiles do not count.)
    private func revealedColorPixels(in view: UIView) -> Int {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        guard let cg = image.cgImage else { return 0 }

        // Redraw into a known RGBA layout so channel order and row padding
        // are not a concern.
        let width = cg.width
        let height = cg.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let ctx = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
            else { return false }
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return 0 }

        var count = 0
        for ix in (height * 15 / 100) * width ..< width * height {
            let green = Int(pixels[ix * 4 + 1])
            let blue = Int(pixels[ix * 4 + 2])
            if green - blue > 80 { count += 1 }
        }
        return count
    }

    /// Stores yesterday's finished, won game as the saved state (restored after the test).
    private func seedFinishedGame(playedAt: Date) {
        let defaults = UserDefaults.standard
        let keys = ["turnState.lv", "stats.lv", "shouldShowHelp"]
        let saved = keys.map { defaults.object(forKey: $0) }
        addTeardownBlock {
            for (key, value) in zip(keys, saved) {
                if let value = value { defaults.set(value, forKey: key) } else { defaults.removeObject(forKey: key) }
            }
        }

        let loc = Locale.lv_LV
        let expected = WordModel("ziema", locale: loc)
        func row(_ word: String) -> RowModel {
            RowModel(word: WordModel(word, locale: loc), expected: expected, isSubmitted: true)
        }
        let blanks = (0 ..< 3).map { _ in RowModel(expected: expected) }
        let finished = DailyState(
            expected: expected,
            date: playedAt,
            rows: [row("salda"), row("meita"), row("ziema")] + blanks,
            state: .finished(isTallied: true, isWon: true),
            firstSubmissionDate: playedAt
        )
        defaults.set(finished.rawValue, forKey: "turnState.lv")
        defaults.removeObject(forKey: "stats.lv")
        defaults.set(false, forKey: "shouldShowHelp")
    }

    /// Shows the game in a real window, structured like `AppView`.
    private func showGame(counter: TurnCounter) throws -> UIWindow {
        let host = UIHostingController(
            rootView: NavigationStack {
                PaletteSetterView {
                    GeometryReader { geometry in
                        GameHost(.lv_LV(simplified: false))
                            .environment(\.rootGeometry, geometry)
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .environment(\.turnCounter, counter)
        )
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        window.rootViewController = host
        window.makeKeyAndVisible()
        addTeardownBlock { window.isHidden = true }
        return window
    }

    /// Opens a finished game, lets midnight pass (optionally while the app is
    /// in the background, so nothing is on screen), then returns to the app.
    private func assertBoardClearsAtMidnight(whileInBackground: Bool) throws {
        DailyReminder.isEnabled = false
        addTeardownBlock { DailyReminder.isEnabled = true }

        let playedAt = Date().addingTimeInterval(-60)
        seedFinishedGame(playedAt: playedAt)

        // Same "day" as the saved game, until the test says midnight has passed.
        let counter = ManualTurnCounter(dayStart: playedAt.addingTimeInterval(-3600))
        let window = try showGame(counter: counter)
        let view: UIView = try XCTUnwrap(window.rootViewController?.view)

        XCTAssertTrue(
            waitUntil(timeout: 20) { self.revealedColorPixels(in: view) > 5000 },
            "Precondition: the finished game should be on screen"
        )

        // Let the finished game settle (reveal animations, stats sheet,
        // completion handling) like it would while the app sits overnight.
        _ = waitUntil(timeout: 8) { false }

        // Midnight passes.
        window.isHidden = whileInBackground
        counter.dayStart = Date()
        _ = waitUntil(timeout: 4) { false }

        // The user (re)opens the app.
        window.isHidden = false

        XCTAssertTrue(
            waitUntil(timeout: 30) { self.revealedColorPixels(in: view) < 100 },
            "The previous day's finished board is still on screen after the day rolled over"
        )
    }

    /// The bug this guards against: the app stayed in memory overnight, the new
    /// day's game was created, but the screen kept showing yesterday's finished board.
    func testBoardClearsWhenDayRollsOverWhileAppIsInBackground() throws {
        try assertBoardClearsAtMidnight(whileInBackground: true)
    }

    func testBoardClearsWhenDayRollsOverWhileAppIsVisible() throws {
        try assertBoardClearsAtMidnight(whileInBackground: false)
    }
}
