import SwiftUI

/// The languages the game can be played in.
///
/// The raw value is stored as the user's default language, and equals the
/// locale's `fileBaseName`, which also names the per-language saved state
/// (`turnState.<raw>`, `stats.<raw>`).
enum AppLanguage: String, CaseIterable, Identifiable {
    case american = "en"
    case british = "en-GB"
    case french = "fr"
    case latvian = "lv"

    /// UserDefaults key holding the language the app opens into.
    static let defaultKey = "cfg.defaultLanguage"

    var id: String {
        rawValue
    }

    var locale: Locale {
        switch self {
        case .american: return .en_US
        case .british: return .en_GB
        case .french: return .fr_FR
        case .latvian: return .lv_LV
        }
    }

    func gameLocale(simplifiedLatvianKeyboard: Bool) -> GameLocale {
        switch self {
        case .american: return .en_US
        case .british: return .en_GB
        case .french: return .fr_FR
        case .latvian: return .lv_LV(simplified: simplifiedLatvianKeyboard)
        }
    }

    /// Seed for picking answers. The British and American lists must
    /// not produce the same word on the same day.
    var seed: Int? {
        switch self {
        case .british: return 1337
        case .american: return 42
        case .french, .latvian: return nil
        }
    }

    /// Key of this language's saved daily game.
    var turnStateKey: String {
        "turnState.\(rawValue)"
    }

    /// The language to show: a language picked for this session wins over the
    /// saved default. `nil` means nothing is chosen yet (first launch), so the
    /// user should be asked.
    static func resolve(stored: String, session: AppLanguage?) -> AppLanguage? {
        session ?? AppLanguage(rawValue: stored)
    }

    /// The saved default, if the user has chosen one.
    static func storedDefault(in defaults: UserDefaults = .standard) -> AppLanguage? {
        defaults.string(forKey: defaultKey).flatMap { AppLanguage(rawValue: $0) }
    }
}

private struct SwitchLanguageKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Opens the language switcher (set by the root view).
    var switchLanguage: () -> Void {
        get { self[SwitchLanguageKey.self] }
        set { self[SwitchLanguageKey.self] = newValue }
    }
}
