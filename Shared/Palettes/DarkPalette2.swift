import SwiftUI



struct DarkPalette2 : Palette
{
    let name = "Dark"
    
    var unknownWordTextColor: Color {
        .red
    }
    
    var maskedFilledStroke: Color {
        maskedEmptyStroke.lighter(3)
    }
    var maskedEmptyStroke: Color {
        maskedFilledFill.lighter(6)
    }
    var wrongLetterStroke: Color {
        wrongLetterFill.lighter(2)
    }
    var wrongPlaceStroke: Color {
        wrongPlaceFill.lighter(2)
    }
    var rightPlaceStroke: Color {
        rightPlaceFill.lighter(2)
    }
    
    let maskedFilledFill: Color = .black.lighter(2)
    let maskedEmptyFill: Color = .black.lighter(2) 
    let wrongLetterFill: Color = .gray.darker(3) 
    let wrongPlaceFill: Color = .yellow.darker(2)
    let rightPlaceFill: Color = .green.darker(2)
    
    let maskedTextColor: Color = .white
    let revealedTextColor: Color = .white
    
    let toastBackground = Color.white
    let toastForeground = Color(hex: 0x121213)
    
    var normalKeyboardFill: Color {
        keyboardFill(for: nil)
    }
    var submitKeyboardFill = Color.blue
    
    var revealedWrongLetterColor: Color {
        revealedTextColor
    }
    
    var inProgressUiLabel: Color {
        wrongPlaceFill.lighter
    }
    
    var completedUiLabel: Color {
        rightPlaceFill.lighter
    }
    
    func keyboardFill(for type: TileBackgroundType?) -> Color {
        guard let type = type else { 
            return wrongLetterFill
        }
        
        switch(type)
        {
        case .darker(let innerType):
            return keyboardFill(for: innerType)
        case .maskedEmpty, .maskedFilled:
            return .red
        case .rightPlace:
            return rightPlaceFill
        case .wrongPlace:
            return wrongPlaceFill
        case .wrongLetter:
            return Color(NativeColor.systemBackground)
        }
    }
    
    func keyboardText(for type: TileBackgroundType?) -> Color {
        guard let type = type else { return toastBackground }
        switch(type) {
        case .darker(let innerType):
            return keyboardText(for: innerType)
        case .maskedEmpty, .maskedFilled:
            return .red
        case .rightPlace:
            return toastBackground
        case .wrongPlace:
            return toastBackground
        case .wrongLetter:
            return Color(NativeColor.systemFill).lighter
        }
    }
}


struct DarkPalette2_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Dark palette v2")
            
            _PaletteInternalTestView()
                .environment(\.palette, DarkPalette2())
        }
        .preferredColorScheme(.dark)
        .padding()
    }
}
