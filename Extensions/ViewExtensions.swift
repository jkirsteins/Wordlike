import SwiftUI

fileprivate struct _DebugView<Wrapped: View>: View {
    @Environment(\.debug)
    var debug: Bool
    
    @ViewBuilder let wrapped: ()->Wrapped
    
    var body: some View {
        if debug {
            wrapped()
        }
    }
}

extension View {
    func debugBelow<T: View>(@ViewBuilder _ content: @escaping ()->T) -> some View {
        return _DebugView {
            self 
            content()
        }
    }
}

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
