import SwiftUI

struct KeyboardButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette
    
    let type: TileBackgroundType?
    
    func fontSize(_ gr: GeometryProxy) -> Double {
        if gr.size.height < 50 {
            // Hardcode some value which is used for
            // small previews (like in a keyboard
            // accessory view)
            return 12
        }
        
        return gr.size.height/1.5
    }
    
    func padding(_ gr: GeometryProxy) -> Double {
        if gr.size.height < 50 {
            // Hardcode some value which is used for
            // small previews (like in a keyboard
            // accessory view)
            return 0
        }
        
        return 4
    }
    
    var computedType: TileBackgroundType {
        return type ?? .wrongLetter
    }
    
    func textColor(_ configuration: Configuration) -> Color {
        palette.keyboardText(for: type).adjust(pressed: configuration.isPressed)
    }
    
    func fillBackground(_ configuration: Configuration) -> Color {
        let result = type == .wrongLetter ?
        palette.keyboardFill(for: type)
        :
        palette.keyboardFill(for: type)
            .darker
        
        return result.adjust(pressed: configuration.isPressed)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            VStack {
                if type == .wrongLetter {
                    Spacer().frame(maxHeight: 2)
                }
                RoundedRectangle(cornerRadius: 4.0)
                    .fill(fillBackground(configuration))
            }
            
            if type != .wrongLetter {
                VStack {
                    RoundedRectangle(cornerRadius: 4.0)
                    .fill(
                            palette.keyboardFill(for: type)
                                .adjust(
                                    pressed: configuration.isPressed)
                            
                        )
                    Spacer().frame(maxHeight: 1)
                }
            }
            
            
            configuration.label
                .foregroundColor(textColor(configuration))
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

/// A keyboard button
struct KeyboardButton: View {
    let letter: MultiCharacterModel
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    @Environment(\.debug) 
    var debug: Bool 
    
    @EnvironmentObject var game: GameState
    
    func insertText() {
        self.game.insertText(letter: letter)
    }
    
    #if os(iOS)
    @Environment(\.verticalSizeClass)
    var verticalSizeClass
    #endif
    
    var isCompactVertically: Bool {
        #if os(iOS)
        return verticalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    /// If we're in compact height (e.g. phone landscape),
    /// allow a smaller keyboard.
    var minHeight: CGFloat {
        if isCompactVertically {
            return 20
        }
        
        return 45
    }
    
    var bestHint: TileBackgroundType? {
        let hints = letter.values.map {
            keyboardHints.hints[$0]
        }
        
        if hints.contains(.rightPlace) {
            return .rightPlace
        }
        
        if hints.contains(.wrongPlace) {
            return .wrongPlace
        }
        
        if hints.contains(.wrongLetter) {
            return .wrongLetter
        }
        
        return nil
    }
    
    var body: some View {
        Button(
            // If debug mode is on, display all
            // possible values this key might submit
            debug ? (letter.values.map { $0.value }).joined() 
            : letter.displayValue, 
            
            action: insertText)
            .disabled(game.isCompleted)
            .frame(minHeight: minHeight)
            .buttonStyle(
                KeyboardButtonStyle(type: bestHint))
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: 50, maxHeight: 50)
    }
    
    init(letter: String, locale: Locale) {
        self.letter = MultiCharacterModel(
            CharacterModel(value: letter, locale: locale)
        )
    }
    
    init(letter: MultiCharacterModel) {
        self.letter = letter
    }
}

struct KeyboardButton_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardButton(letter: "Q", locale: .en_US)
            .environmentObject(GameState())
            .scaleEffect(4.0)
        
        VStack {
            Text("Keyboard with Light palette v2")
            
            _PaletteInternalTestView()
                .environment(\.palette, LightPalette2())
        }.padding()
    }
}
