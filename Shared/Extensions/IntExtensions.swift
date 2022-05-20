import SwiftUI

fileprivate var ordinalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()


extension Int {
    var ordinal: String? {
        return ordinalFormatter.string(from: NSNumber(value: self))
    }
}
