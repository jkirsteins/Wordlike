import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

protocol Palette
{
    var maskedFilledStroke: Color { get }
    var maskedEmptyStroke: Color { get }
    var wrongLetterStroke: Color { get }
    var wrongPlaceStroke: Color { get }
    var rightPlaceStroke: Color { get }
    
    var maskedFilledFill: Color { get }
    var maskedEmptyFill: Color { get }
    var wrongLetterFill: Color { get }
    var wrongPlaceFill: Color { get }
    var rightPlaceFill: Color { get }
}

struct DarkPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x565758)
    let maskedEmptyStroke: Color = Color(hex: 0x3a3a3c)
    let wrongLetterStroke: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceStroke: Color = Color(hex: 0xb59f3b)
    let rightPlaceStroke: Color = Color(hex: 0x538d4e)
    
    let maskedFilledFill: Color = Color(hex: 0x121213)
    let maskedEmptyFill: Color = Color(hex: 0x121213)
    let wrongLetterFill: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceFill: Color = Color(hex: 0xb59f3b)
    let rightPlaceFill: Color = Color(hex: 0x538d4e)
}

enum TileBackgroundType
{
    case maskedEmpty
    case maskedFilled
    case wrongLetter
    case wrongPlace
    case rightPlace
    
    func strokeColor(from palette: Palette) -> Color {
        switch(self) {
            case .maskedEmpty:
            return palette.maskedEmptyStroke
        case .maskedFilled:
            return palette.maskedFilledStroke
        case .wrongLetter:
            return palette.wrongLetterStroke
        case .wrongPlace:
            return palette.wrongPlaceStroke
        case .rightPlace:
            return palette.rightPlaceStroke
        }
    }
    
    func fillColor(from palette: Palette) -> Color {
        switch(self) {
        case .maskedEmpty:
            return palette.maskedEmptyFill
        case .maskedFilled:
            return palette.maskedFilledFill
        case .wrongLetter:
            return palette.wrongLetterFill
        case .wrongPlace:
            return palette.wrongPlaceFill
        case .rightPlace:
            return palette.rightPlaceFill
        }
    }
}

struct TileBackgroundView: View {
    let type: TileBackgroundType
    
    @Environment(\.palette) var palette: Palette
    
    var body: some View {
        Rectangle()
            .stroke(
                type.strokeColor(from: palette), 
                lineWidth: 4)
            .background(
                type.fillColor(from: palette))
    }
}

struct TileBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TileBackgroundView(
                type: .wrongLetter)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
            
            TileBackgroundView(
                type: .maskedEmpty)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
            
            TileBackgroundView(
                type: .maskedFilled
            )
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
            
            TileBackgroundView(type: .wrongPlace
            )
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
            
            TileBackgroundView(type: .rightPlace
            )
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: 100)
        }
    }
}
