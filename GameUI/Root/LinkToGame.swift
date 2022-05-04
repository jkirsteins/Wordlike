import SwiftUI

/// Creates a standardized NavigationLink
/// to a GameHost instance.
struct LinkToGame: View {
    let locale: GameLocale
    let validator: WordValidator
    let caption: String? 
    
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.globalTapCount)
    var globalTapCount: Binding<Int>
    
    @Environment(\.debug) 
    var debug: Bool
    
    init(locale: GameLocale, caption: String? = nil, seed: Int? = nil) {
        self.locale = locale 
        self.validator = WordValidator(locale: locale, seed: seed)
        self.caption = caption
    }
    
    init(locale: GameLocale, validator: WordValidator, caption: String? = nil) {
        self.locale = locale 
        self.validator = validator
        self.caption = caption
    }
    
    var body: some View {
        NavigationLink(destination: {
            GeometryReader { gr in
                GameHost(locale, validator: validator)
                /* We set the environment explicitly, because
                 it will not be handled by the palette wrapper
                 (it is instantiated, not nested) */
                    .environment(\.rootGeometry, gr)
                    .environment(\.globalTapCount, globalTapCount)
                    .environment(\.debug, debug)
                    .environment(\.palette, palette)
                    .toolbar {
                        /* HACK: workaround for SwiftUI
                         NavigationView issues (maybe?)
                         
                         Ever since the first list started
                         using a .bottombar toolbar item,
                         the gamehost view has a jarring jump where area available for
                         the content is reduced after the
                         navigationview transition.
                         
                         Having an empty textview in the bottombar ensures that this area
                         is unavailable from the start,
                         and the game board doesn't appear
                         to be jumpy.*/
                        ToolbarItem(placement: .bottomBar) {
                            Text("")
                        }
                    }
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

