import SwiftUI

struct Tile: View {
    static let MAX_SIZE = CGFloat(75)
    static let MIN_SIZE = CGFloat(24)
    
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.showFocusHint) 
    var showFocusHint: Bool
    
    let model: TileModel
    
    @State var scaleSize = CGSize(width: 1.0, height: 1.0)
    
    let pulseHalfDuration = 0.25 / 4.0
    
    var letter: String { model.letter }
    var type: TileBackgroundType { model.state }
    
    var isEmpty: Bool {
        letter == ""
    }
    
    init() {
        self.model = TileModel()
    }
    
    init(model: TileModel) {
        self.model = model
    }
    
    init(_ letter: String) {
        self.model = TileModel(
            letter: letter, 
            state: letter.count == 0 ? .maskedEmpty : .maskedFilled)
    }
    
    init(_ letter: String, _ type: TileBackgroundType) {
        self.model = TileModel(letter: letter, state: type)
    }
    
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
    
    var isMasked: Bool {
        type == .maskedEmpty || type == .maskedFilled
    }
    
    var foregroundColor: Color {
        isMasked ? palette.maskedTextColor : palette.revealedTextColor
    }
    
    var body: some View {
        GeometryReader { gr in 
            ZStack {
                TileBackgroundView( 
                    type: type)
                
                if showFocusHint {
                    // This is the cursor branch.
                    // 
                    // Text() modifiers need to be same
                    // here and in the letter branch
                    // (except animations)
                    ZStack {
                        
                    Text("_") 
                        .font( 
                            .system(size: fontSize(gr), weight: .bold))
                        .textCase(.uppercase)
                        .padding(padding(gr))
                        .scaledToFit()
                        .minimumScaleFactor(0.19)
                        .lineLimit(1)
                        .foregroundColor(foregroundColor)
                        .blinking(duration: 0.5)
                    }
                    
                }
                
                if !showFocusHint, let letter = letter {
                    Text(letter) 
                        .font( 
                            .system(size: fontSize(gr), weight: .bold))
                        .textCase(.uppercase)
                        .padding(padding(gr))
                        .scaledToFit()
                    
                    /* We need a small minimumScaleFactor 
                     otherwise filled/non-filled masked
                     tiles might have different sizes */
                        .minimumScaleFactor(0.19)
                    
                        .lineLimit(1)
                        .foregroundColor(foregroundColor)  
                }
            }
        }
        // frame w maxWidth must come before aspectRatio
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        
        // aspectRatio must come after maxWidth
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        .frame(
            maxWidth: Self.MAX_SIZE, 
            maxHeight: Self.MAX_SIZE)
        .frame(
            minWidth: Self.MIN_SIZE, 
            minHeight: Self.MIN_SIZE)
        .aspectRatio(1, contentMode: .fit)
        
        .scaleEffect(self.scaleSize)
        
        .animation(
            Animation.easeInOut(duration: pulseHalfDuration),
            value: self.scaleSize)
        
        .onAppear {
            // TODO: bulge animation when typing
        }
    }
}

struct Tile_Previews: PreviewProvider {
    static let wa = Array("fuels")
    static var previews: some View {
        PaletteSetterView {
            VStack {
                Text("Blinking cursor test")
                Tile().environment(\.showFocusHint, true)
            }
        }
        
        VStack {
            Tile(model: TileModel(letter: "Q", state: .maskedFilled))
            
            Tile(model: TileModel(letter: "Q", state: .rightPlace, justTyped: true))
        }
    }
}
