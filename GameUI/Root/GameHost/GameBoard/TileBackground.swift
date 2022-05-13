import SwiftUI

enum TileBackgroundType : Equatable, Hashable
{
    case maskedEmpty
    case maskedFilled
    case wrongLetter
    case wrongPlace
    case rightPlace
    indirect case darker(TileBackgroundType)
    
    var isMasked: Bool {
        switch(self) {
            case .maskedEmpty, .maskedFilled:
            return true 
            default:
            return false
        }
    }
    
    func strokeColor(from palette: Palette) -> Color {
        switch(self) {
            case .darker(let type):
            return type.strokeColor(from: palette).darker
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
        case .darker(let type):
            return type.strokeColor(from: palette).darker
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
    
    let cornerRadius = CGFloat(0.0)
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                type.strokeColor(from: palette), 
                lineWidth: 1)
            .background(
                type.fillColor(from: palette))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
        
        HStack {
            VStack {
                Tile("Q", .wrongLetter)
                Tile("Q", .maskedEmpty)
                Tile("Q", .maskedFilled)
                Tile("Q", .wrongPlace)
                Tile("Q", .rightPlace)
            }
            
            VStack {
                Tile("Q", .wrongLetter)
                Tile("Q", .maskedEmpty)
                Tile("Q", .maskedFilled)
                Tile("Q", .wrongPlace)
                Tile("Q", .rightPlace)
            }.environment(\.palette, LightPalette())
        }
    }
}
