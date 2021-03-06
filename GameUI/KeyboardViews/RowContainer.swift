import SwiftUI

/// This is used as the root container for
/// keyboard rows, so different keyboards can
/// have the same shared constraints (e.g. maxHeight).
///
/// It can also be helpful to add borders for debugging etc.
struct RowContainer<Content: View> : View {
    
    let spacing: CGFloat
    
    let MAX_HEIGHT = CGFloat(75)
    
    @ViewBuilder var content: ()->Content
    
    @Environment(\.debug) var debug: Bool
    
    var body: some View {
        HStack(spacing: spacing) {
            content()
        }
//        .frame(maxHeight: MAX_HEIGHT)
        .border(debug ? Color.red : Color.clear)
    }
}
