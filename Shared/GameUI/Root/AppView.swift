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

    /// The language the app opens into. Empty until the user has chosen one.
    @AppStorage(AppLanguage.defaultKey) var defaultLanguageID: String = ""

    /// A language picked from the menu for this session only (the default is unchanged).
    @State var sessionLanguage: AppLanguage? = nil

    @State var isSwitchingLanguage = false

    @State var globalTapCount = 0

    @State var tapDelegate: GlobalTapDelegate? = nil

    /// What to show; `nil` means no language is chosen yet.
    var language: AppLanguage? {
        AppLanguage.resolve(stored: defaultLanguageID, session: sessionLanguage)
    }

    var body: some View {
        innerBody
            .trackRUMView(name: "Game")
    }

    @ViewBuilder var content: some View {
        if let language = language {
            GeometryReader { gr in
                GameHost(
                    language.gameLocale(simplifiedLatvianKeyboard: isSimplifiedLatvianKeyboard),
                    seed: language.seed
                )
                .environment(\.rootGeometry, gr)
                .onAppear { trackFirstInteraction(language) }
            }
            .padding()
            // A different language is a different game: rebuild it from scratch.
            .id(language)
        } else {
            LanguagePicker(prompt: "Default language") { chosen in
                defaultLanguageID = chosen.rawValue
            }
        }
    }

    var innerBody: some View {
        NavigationStack {
            PaletteSetterView {
                content
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            self.tapDelegate = GlobalTapDelegate($globalTapCount)
            UIApplication.shared.addGestureRecognizer(
                tapDelegate!
            )
        }
        .onChange(of: defaultLanguageID) { _ in
            // The default was changed (Settings): show it right away,
            // and remind about its word instead.
            sessionLanguage = nil
            DailyReminder.rescheduleForDefaultLanguage(turnCounter: turnCounter)
        }
        .sheet(isPresented: $isSwitchingLanguage) {
            PaletteSetterView {
                LanguagePicker(prompt: "Switch language", selected: language) { chosen in
                    sessionLanguage = chosen
                    isSwitchingLanguage = false
                }
            }
            .environment(\.turnCounter, turnCounter)
        }
        .environment(
            \.globalTapCount,
            $globalTapCount
        )
        .environment(\.turnCounter, turnCounter)
        .environment(\.debug, innerDebug || outerDebug)
        .environment(\.toggleDebug) { innerDebug.toggle() }
        .environment(\.switchLanguage) { isSwitchingLanguage = true }
    }

    private func trackFirstInteraction(_ language: AppLanguage) {
        var attrs: [String: any Encodable] = [
            "game_locale": language.rawValue,
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
