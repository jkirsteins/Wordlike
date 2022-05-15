import SwiftUI

fileprivate struct DebugBorder<Content: View>: View {
    let color: Color
    @ViewBuilder let content: ()->Content 
    
    @Environment(\.debug)
    var debug: Bool
    
    var body: some View {
        content().border(debug ? color : .clear)
    }
}

extension View {
    func screenshotView(_ closure: @escaping ScreenshotMakerClosure) -> some View {
        let screenshotView = ScreenshotMakerView(closure)
        return overlay(screenshotView.allowsHitTesting(false))
    }
    
    func debugBorder(_ color: Color) -> some View {
        DebugBorder(color: color) {
            self
        }
    }
}
