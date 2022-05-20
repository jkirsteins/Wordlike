import SwiftUI

/// Creates a standardized NavigationLink
/// to a GameHost instance.
struct LinkToGame: View {
    let locale: GameLocale
    let caption: String? 
    let seed: Int?
    
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.globalTapCount)
    var globalTapCount: Binding<Int>
    
    @Environment(\.debug) 
    var debug: Bool
    
    init(locale: GameLocale, caption: String? = nil, seed: Int? = nil) {
        self.locale = locale 
        self.seed = seed
        self.caption = caption
    }
    
    var body: some View {
        NavigationLink(destination: {
            GeometryReader { gr in
                GameHost(locale, seed: seed)
                /* We set the environment explicitly, because
                 it will not be handled by the palette wrapper
                 (it is instantiated, not nested) */
                    .environment(\.rootGeometry, gr)
                    .environment(\.globalTapCount, globalTapCount)
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
            LanguageLinkLabel(
                locale, 
                extraCaption: caption)
        })
    }
}

