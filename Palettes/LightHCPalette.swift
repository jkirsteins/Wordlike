import SwiftUI

struct LightHCPalette : Palette
{
    let wrapped = LightPalette2()
    
    let name = "Light (high contrast)"
    
    var maskedFilledStroke: Color {
        wrapped.maskedFilledStroke
    } 
    
    var maskedEmptyStroke: Color {
        wrapped.maskedEmptyStroke
    }
    
    var wrongLetterStroke: Color {
        wrapped.wrongLetterStroke
    }
    
    var wrongPlaceStroke: Color {
        wrongPlaceFill.darker
    }
    
    var rightPlaceStroke: Color {
        rightPlaceFill.darker
    }
    
    var maskedFilledFill: Color {
        wrapped.maskedFilledFill
    }
    
    var maskedEmptyFill: Color {
        wrapped.maskedEmptyFill
    }
    
    var wrongLetterFill: Color {
        wrapped.wrongLetterFill
    }
    
    let wrongPlaceFill: Color = Color(hex: 0x85C0f9)
    let rightPlaceFill: Color = Color(hex: 0xF5793A)
    
    var maskedTextColor: Color {
        wrapped.maskedTextColor
    }
    
    var revealedTextColor: Color {
        wrapped.revealedTextColor
    }
    
    var toastBackground: Color {
        wrapped.toastBackground
    }
    
    var toastForeground: Color {
        wrapped.toastForeground
    }
    
    var normalKeyboardFill: Color {
        wrapped.normalKeyboardFill
    }
    
    var submitKeyboardFill: Color {
        wrapped.submitKeyboardFill
    }
    
    func keyboardText(for type: TileBackgroundType?) -> Color {
        wrapped.keyboardText(for: type)
    }
    
    func keyboardFill(for type: TileBackgroundType?) -> Color {
        switch(type)
        {
        case .darker(let innerType):
            return keyboardFill(for: innerType)
        case .rightPlace:
            return rightPlaceFill
        case .wrongPlace:
            return wrongPlaceFill
        default:
            return wrapped.keyboardFill(for: type)
        }
    }
}

struct LightHCPalette_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Light HC palette")
            
            _PaletteInternalTestView()
                .environment(\.palette, LightHCPalette())
        }
        .preferredColorScheme(.light)
        .padding()
    }
}
