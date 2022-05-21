import SwiftUI

// This is more a "game mode" than just a locale
// E.g. lv_LV contains game mode config.
enum GameLocale 
{
    case unknown
    case ee_EE
    case en_US
    case en_GB
    case fr_FR
    case lv_LV(simplified: Bool)
    
    /// For use with @AppStateStorage etc.
    var turnStateKey: String {
        "turnState.\(self.fileBaseName)"
    }
    
    var nativeLocale: Locale {
        switch(self) {
        case .unknown:
            return Locale.current
        case .en_GB:
            return .en_GB
        case .en_US:
            return .en_US
        case .fr_FR:
            return .fr_FR
        case .lv_LV(_):
            return .lv_LV
        case .ee_EE:
            return .ee_EE
        }
    }
    
    var flag: String {
        nativeLocale.flag
    }
    
    var localeDisplayName: String {
        nativeLocale.displayName
    }
    
    var fileBaseName: String {
        nativeLocale.fileBaseName
    }
}
