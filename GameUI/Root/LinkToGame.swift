import SwiftUI

/// Creates a standardized NavigationLink
/// to a GameHost instance.
struct LinkToGame: View {
    let locale: String
    
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.debug) 
    var debug: Bool
    
    var body: some View {
        NavigationLink(destination: {
            GeometryReader { gr in
                GameHost(locale)
                /* We set the environment explicitly, because
                 it will not be handled by the palette wrapper
                 (it is instantiated, not nested) */
                    .environment(\.rootGeometry, gr)
                    .environment(\.debug, debug)
                    .environment(\.palette, palette)
            }
            /* Padding must not be inside the GeometryReader
             because the geometry reader width is used
             downstream (through .rootGeometry) to set maxWidth.
             
             So if padding is set inside on GameHostView,
             child views will overflow bounds. */
            .padding()
        }, label: {
            LanguageLinkLabel(locale)
        })
    }
}

