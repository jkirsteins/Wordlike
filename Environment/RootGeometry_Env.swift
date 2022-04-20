import SwiftUI

fileprivate struct RootGeometryKey: EnvironmentKey {
    static let defaultValue: GeometryProxy? = nil
}

extension EnvironmentValues {
    var rootGeometry: GeometryProxy? {
        get { self[RootGeometryKey.self] }
        set { self[RootGeometryKey.self] = newValue }
    }
}
