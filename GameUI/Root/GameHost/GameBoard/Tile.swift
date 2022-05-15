import SwiftUI

fileprivate let MAX_SIZE = CGFloat(75)
fileprivate let MIN_SIZE = CGFloat(24)

extension Tile where Background == InternalFillColor {
    init() {
        self.model = nil
        self.bg = TileBackgroundView(type: .maskedEmpty)
        self.aspectRatio = 1.0
    }
    
    init(model: TileModel?) {
        self.model = model
        self.bg = TileBackgroundView(type: model?.state ?? .maskedEmpty)
        self.aspectRatio = 1.0
    }
    
    init(_ letter: String) {
        let t: TileBackgroundType = letter.count == 0 ? .maskedEmpty : .maskedFilled
        self.model = TileModel(
            letter: letter, 
            state: t)
        self.bg = TileBackgroundView(type: t)
        self.aspectRatio = 1.0
    }
    
    init(_ letter: String, _ type: TileBackgroundType) {
        self.model = TileModel(letter: letter, state: type)
        self.bg = TileBackgroundView(type: type)
        self.aspectRatio = 1.0
    }
}

struct Tile<Background: View>: View {
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.showFocusHint) 
    var showFocusHint: Bool
    
    let model: TileModel?
    
    @State var pulsing = false
    
    let bg: TileBackgroundView<Background>
    let aspectRatio: CGFloat
    
    var letter: String { 
        model?.letter ?? "" 
    }
    
    var type: TileBackgroundType { 
        model?.state ?? .maskedEmpty 
    }
    
    var isEmpty: Bool {
        letter == ""
    }
    
    init(
type: TileBackgroundType, 
lineWidth: CGFloat, 
    aspectRatio: CGFloat,
    @ViewBuilder _ bgItem: ()->Background) {
        self.model = nil
        self.aspectRatio = aspectRatio
        self.bg = TileBackgroundView(
            type: type, 
            lineWidth: lineWidth, 
            background: bgItem())
    }
    
    func fontSize(_ gr: GeometryProxy) -> Double {
        
        if gr.size.height < 30 {
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
        guard type != .wrongLetter else {
            return palette.revealedWrongLetterColor
        }
        
        return isMasked ? palette.maskedTextColor : palette.revealedTextColor
    }
    
    let maxd = Double(3.0)
    
    var randRotate: Double {
        let x = maxd * drand48()
        let r = (maxd/2.0) - x
        return r
    }
    
    var body: some View {
        GeometryReader { gr in 
            ZStack {
                TileBackgroundView(type: .darker(type))
                    .overlay(
                        VStack {
                            bg
                            //                            Spacer().frame(maxHeight: 2)
                        }
                    )
                    .rotationEffect(
                        .degrees(randRotate)
                    )
                
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
        /* aspectRatio must come before AND after frame
         (see the visual test for aspect ratios)
         */
        // -- start: aspectRatio->frame->aspectRatio
        .aspectRatio(aspectRatio, contentMode: .fit)
        .frame(
            minWidth: MIN_SIZE,
            maxWidth: MAX_SIZE)
        .aspectRatio(aspectRatio, contentMode: .fit)
        // -- end: aspectRatio->frame->aspectRatio
        .onChange(of: self.model?.letter) { (nl: String?) in
            guard nl != nil else {
                self.pulsing = false 
                return 
            }
            self.pulsing = true
        }
        
        .pulsing(pulsing: $pulsing, 
                 maxScale: 1.1,
                 duration: 0.125)
    }
}

struct Tile_Previews: PreviewProvider {
    static let wa = Array("fuels")
    static let locales: [Locale] = [
        .lv_LV, .en_GB, .en_US, .fr_FR
    ]
    static var previews: some View {
        
        VStack {
            Text("Check that aspect ratio is preserved")
            Divider()
            
            VStack {
                Tile("A")
                    .border(.red)
                Tile("B")
                    .border(.red)
            }.frame(maxWidth: 30)
            
            HStack {
                Tile("A")
                    .border(.red)
                Tile("B")
                    .border(.red)
                Spacer()
            }.frame(maxHeight: 30)
        }
        
        VStack {
            TileFlag()
                .environment(\.locale, .lv_LV)
            
        PaletteSetterView {
            HStack {
                ForEach(locales, id: \.self) { loc in
                    Tile(type: .maskedEmpty, lineWidth: 1, aspectRatio: Flag.aspectRatio) {
                        Flag()
                    }.environment(\.locale, loc)
                }
            }.padding()
        }
        }
        
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
