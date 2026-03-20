import Foundation

extension Double {
    static var random: Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
}
