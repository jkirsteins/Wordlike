import SwiftUI

extension Locale {
    /// Locales shown in the main menu. EN/GB/FR are hidden (not
    /// removed): their code, resources, and stats remain intact.
    static var supportedLocales: [Locale] {
        [.lv_LV]
    }

    var flag: String {
        switch self {
        case .en_US:
            return "🇺🇸"
        case .en_GB:
            return "🇬🇧"
        case .fr_FR:
            return "🇫🇷"
        case .lv_LV:
            return "🇱🇻"
        case .ee_EE:
            return "🇪🇪"
        default:
            return ""
        }
    }

    var displayName: LocalizedStringKey {
        switch self {
        case .en_US:
            return "American"
        case .en_GB:
            return "British"
        case .fr_FR:
            return "Français"
        case .lv_LV:
            return "Latviski"
        case .ee_EE:
            return "Eesti"
        default:
            fatalError("Do not use unknown locale")
        }
    }

    var fileBaseName: String {
        switch self {
        case .en_GB:
            return "en-GB"
        case .en_US:
            return "en"
        case .fr_FR:
            return "fr"
        case .ee_EE:
            return "ee_EE"
        case .lv_LV:
            return "lv"
        default:
            fatalError("Invalid locale")
        }
    }

    static var ee_EE: Locale {
        Locale(identifier: "ee_EE")
    }

    static var lv_LV: Locale {
        Locale(identifier: "lv_LV")
    }

    static var en_US: Locale {
        Locale(identifier: "en_US")
    }

    static var en_GB: Locale {
        Locale(identifier: "en_GB")
    }

    static var fr_FR: Locale {
        Locale(identifier: "fr_FR")
    }
}
