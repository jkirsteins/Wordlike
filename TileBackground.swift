import SwiftUI

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
            .strokeBorder(
                type.strokeColor(from: palette), 
                lineWidth: 2)
            .background(
                type.fillColor(from: palette))
    }
}

struct TileBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
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
            }.environment(\.palette, LightPalette())
        }
    }
}
