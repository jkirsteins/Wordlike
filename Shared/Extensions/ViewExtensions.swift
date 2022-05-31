import SwiftUI

fileprivate struct _DebugView<Wrapped: View, WrappedDebug: View>: View {
    @Environment(\.debug)
    var debug: Bool
    
    @ViewBuilder let wrapped: ()->Wrapped
    @ViewBuilder let wrappedDebug: ()->WrappedDebug
    
    var body: some View {
        if debug {
            VStack {
                wrapped()
                wrappedDebug()
            }
        } else {
            wrapped()
        }
    }
}

extension View {
    func debugBelow<T: View>(@ViewBuilder _ content: @escaping ()->T) -> some View {
        return _DebugView(
            wrapped: { self }, 
            wrappedDebug: content
        )
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
#if os(iOS)
    func screenshotView(_ closure: @escaping ScreenshotMakerClosure) -> some View {
        let screenshotView = ScreenshotMakerView(closure)
        return overlay(screenshotView.allowsHitTesting(false))
    }
#endif
    
    func debugBorder(_ color: Color) -> some View {
        DebugBorder(color: color) {
            self
        }
    }
    
    func safeTint(_ tint: Color) -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(self.tint(tint))
        } else {
            return AnyView(self)
        }
    }
}

extension View {
    /* NOTE: BE CAREFUL ON iOS14
     The fallback on iOS14 is to use .sheet() modifier.
     
     This will break, if safeSharingSheet() is invoked on the same
     level as another .sheet() modifier.
     
     The call site should wrap this call in .background(EmptyView().safeSharingSheet...)
     */
    func safeSharingSheet(
        isSharing: Binding<Bool>,
        activityItems: Binding<[UIActivityItemSource]>,
        callback: @escaping ()->()) -> some View
    {
        if #available(iOS 15.0, *) {
            return AnyView(self.sheetWithDetents(
                isPresented: isSharing,
                detents: [.medium(),.large()],
                onDismiss: {
                },
                content: {
                    ActivityViewController(
                        activityItems: activityItems,
                        callback: callback)
                    .ignoresSafeArea()
                }))
        } else {
            return AnyView(
                self.sheet(isPresented: isSharing, onDismiss: {}, content: {
                ActivityViewController(
                    activityItems: activityItems,
                    callback: callback)
                .ignoresSafeArea()
            }))
        }
    }
}
