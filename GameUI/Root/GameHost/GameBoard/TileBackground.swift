import SwiftUI

enum TileBackgroundType : Equatable, Hashable
{
    case maskedEmpty
    case maskedFilled
    case wrongLetter
    case wrongPlace
    case rightPlace
    indirect case darker(TileBackgroundType)
    
    static var randomNonDark: TileBackgroundType {
        switch(drand48()) {
        case let x where x > 0.0 && x <= 0.2:
            return .wrongPlace
        case let x where x > 0.2 && x <= 0.3:
            return .rightPlace
        case let x where x > 0.3 && x <= 0.4:
            return .wrongLetter
        case let x where x > 0.4 && x <= 0.5:
            return .maskedFilled
        default:
            return .maskedEmpty
        }
    }
    
    static func random(not exclude: TileBackgroundType) -> TileBackgroundType {
        let res = Self.random 
        if res == exclude {
            return .random(not: exclude)
        }
        return res
    }
    
    static var random: TileBackgroundType {
        switch(drand48()) {
        case let x where x > 0.1 && x <= 0.2:
            return .darker(.randomNonDark)
        default:
            return .randomNonDark
        }
    }
    
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

struct InternalFillColor: View {
    @Environment(\.palette)
    var palette: Palette
    
    let type: TileBackgroundType
    
    var body: some View {
        type.fillColor(from: palette)
    }
}

extension TileBackgroundView where Background == InternalFillColor {
    init(type: TileBackgroundType) {
        self.type = type
        self.background = {
            InternalFillColor(type: type)
        } 
        self.lineWidth = 1.0
    }
}

struct TileBackgroundView<Background: View>: View {
    let type: TileBackgroundType
    var background: ()->Background 
    
    @Environment(\.palette) var palette: Palette
    
    let cornerRadius = CGFloat(0.0)
    let lineWidth: CGFloat
    
    init(
        type: TileBackgroundType, 
        lineWidth: CGFloat, 
        @ViewBuilder background: @escaping ()->Background) 
    {
        self.type = type 
        self.background = background
        self.lineWidth = lineWidth
    }
    
    init(type: TileBackgroundType, lineWidth: CGFloat, background: Background) {
        self.type = type 
        self.background = { background }
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(
                type.strokeColor(from: palette), 
                lineWidth: lineWidth)
            .background(background())
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct TileBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        TileBackgroundView(
            type: .maskedEmpty, 
            lineWidth: 2.0
        ) {
            Flag()
                .environment(\.locale, .lv_LV)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 100, maxHeight: 100)
        
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
