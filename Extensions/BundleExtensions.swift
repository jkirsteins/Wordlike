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
}
