import SwiftUI

/// This is used as the root container for
/// keyboard views, so different keyboards can
/// have the same shared constraints (e.g. maxWidth).
struct KeyboardContainer<Content: View> : View {
    
    let spacing: CGFloat 
    
    @ViewBuilder var content: ()->Content
    
    @Environment(\.rootGeometry) 
    var rootGeometry: GeometryProxy?
    
    @Environment(\.debug) 
    var debug: Bool
    
    var body: some View {
        VStack(spacing: spacing) {
            content()
        }
        /* Padding must come before 
        wrapping in ideal/max size frame */
        .padding()
        .frame(
            idealWidth: rootGeometry?.size.width,
            maxWidth: rootGeometry?.size.width)
        
        /* Without fixedSize(), rotations might
         cause the view to resize */
        .fixedSize()
        
        .border(debug ? .green : .clear)
    }
}
