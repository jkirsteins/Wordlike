import SwiftUI

extension Bundle {
    var displayName: String {
        if let result = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return result 
        }
        
        if let result = object(forInfoDictionaryKey: "CFBundleName") as? String {
            return result 
        }
        
        return "Game"
    }
    
    #if os(iOS)
    var icon: UIImage? {
      
      if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
         let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
         let files = primary["CFBundleIconFiles"] as? [String],
         let icon = files.last
      {
        return UIImage(named: icon)
      }
      
      return nil
    }
    #endif
}
