import SwiftUI

import SwiftUI

struct LightPalette2 : Palette
{
    let name = "Light"
    
    var unknownWordTextColor: Color {
        .red.darker
    }
    
    let maskedFilledStroke: Color = .black
    let maskedEmptyStroke: Color = .gray
    let wrongLetterStroke: Color = .black
    
    var wrongPlaceStroke: Color { 
        wrongPlaceFill.darker
    }
    
    var rightPlaceStroke: Color {
        rightPlaceFill.darker
    }
    
    let maskedFilledFill: Color = .white
    let maskedEmptyFill: Color = .white
    let wrongLetterFill: Color = .white.darker
    let wrongPlaceFill: Color = .yellow
    let rightPlaceFill: Color = .green
    
    let maskedTextColor: Color = .black
    let revealedTextColor: Color = .white
    
    let toastBackground = Color(hex: 0x121213)
    let toastForeground = Color.white
    
    var normalKeyboardFill: Color {
        keyboardFill(for: nil)
    }
    var submitKeyboardFill = Color.blue
    
    var revealedWrongLetterColor: Color {
        revealedTextColor
    }
    
    var inProgressUiLabel: Color {
        wrongPlaceFill.darker
    }
    
    var completedUiLabel: Color {
        rightPlaceFill.darker
    }
    
    func keyboardFill(for type: TileBackgroundType?) -> Color {
        guard let type = type else { 
            return Color(hex: 0xefefef) 
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
            return .white
        }
    }
    
    func keyboardText(for type: TileBackgroundType?) -> Color {
        guard let type = type else { return .black }
        switch(type) {
        case .darker(let innerType):
            return keyboardText(for: innerType)
        case .maskedEmpty, .maskedFilled:
            return .black
        case .rightPlace:
            return .white
        case .wrongPlace:
            return .white
        case .wrongLetter:
            return .white.darker
        }
    }
}

struct LightPalette2_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Light palette v2")
            
            _PaletteInternalTestView()
                .environment(\.palette, LightPalette2())
        }.padding()
    }
}
