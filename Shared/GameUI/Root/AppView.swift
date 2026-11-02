import DatadogRUM
import LinkPresentation
import SwiftUI
import UniformTypeIdentifiers

/// Root of the app. It opens directly into the Latvian game.
///
/// The language menu (`NavigationList`, `LinkToGame`) is parked and
/// not part of the user-facing flow, but is kept in the project in case
/// other languages return.
struct AppView: View {
    let turnCounter = CalendarDailyTurnCounter.current(
        start: WordValidator.MAR_22_2022
    )
//    let turnCounter = BucketTurnCounter(start: Date(), bucket: 10)

    /// This is propogated through the environment
    /// and can trigger debug borders or messages.
    @State var innerDebug = false

    /// Outer debug can be set by e.g. MockDevice etc.
    @Environment(\.debug) var outerDebug: Bool

    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY) var isSimplifiedLatvianKeyboard: Bool = false

    @State var globalTapCount = 0

    @State var tapDelegate: GlobalTapDelegate? = nil

    var body: some View {
        innerBody
            .trackRUMView(name: "Game")
    }

    var innerBody: some View {
        NavigationStack {
            PaletteSetterView {
                GeometryReader { gr in
                    GameHost(.lv_LV(simplified: isSimplifiedLatvianKeyboard))
                        .environment(\.rootGeometry, gr)
                        .onAppear(perform: trackFirstInteraction)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.tapDelegate = GlobalTapDelegate($globalTapCount)
            UIApplication.shared.addGestureRecognizer(
                tapDelegate!
            )
        }
        .environment(
            \.globalTapCount,
            $globalTapCount
        )
        .environment(\.turnCounter, turnCounter)
        .environment(\.debug, innerDebug || outerDebug)
        .environment(\.toggleDebug) { innerDebug.toggle() }
    }

    private func trackFirstInteraction() {
        var attrs: [String: any Encodable] = [
            "game_locale": GameLocale.lv_LV(simplified: false).fileBaseName,
        ]
        if !DatadogSetup.hasTrackedFirstInteraction {
            DatadogSetup.hasTrackedFirstInteraction = true
            let elapsedMs = Int(
                Date().timeIntervalSince(DatadogSetup.launchDate) * 1000
            )
            attrs["time_to_first_interaction_ms"] = elapsedMs
        }
        Analytics.shared.trackAction(name: "language.switched", attributes: attrs)
    }
}

struct AppView_Previews: PreviewProvider {
    static let configurationsWithDupes = [
        .inch58_iPhone11Pro,
        .inch58_iPhone12Pro,
        .inch4_iPhoneSE,
        .inch4_iPhoneSE2,
    ]
        + MockDeviceConfig.mandatoryScreenshotConfigs +
        [
            .inch129_iPadPro4,
        ]

    static var configurations: [MockDeviceConfig] {
        Array(Set(configurationsWithDupes)).sorted {
            let ix1 = configurationsWithDupes.firstIndex(of: $0)!
            let ix2 = configurationsWithDupes.firstIndex(of: $1)!

            return ix1 < ix2
        }
    }

    static var previews: some View {
        ForEach(configurations) {
            MockDevice(config: $0) {
                AppView()
            }
        }
    }
}
