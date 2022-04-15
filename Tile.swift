import SwiftUI

fileprivate struct SideLengthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 150
}

extension EnvironmentValues {
    var sideLength: CGFloat {
        get { self[SideLengthKey.self] }
        set { self[SideLengthKey.self] = newValue }
    }
}

extension EnvironmentValues {
    var showFocusHint: Bool {
        get { self[ShowFocusHintKey.self] }
        set { self[ShowFocusHintKey.self] = newValue }
    }
}

struct ShowFocusHintKey: EnvironmentKey {
    static let defaultValue: Bool = false 
}

struct Tile: View {
    @Environment(\.palette) var palette: Palette
    @Environment(\.sideLength) var sideLength: CGFloat
    
    @State var rotate: Double = 0
    @State var rotateOut: Double = 0
    
    @State var flip = false
    
    /// The desired background type at a time. Accessed
    /// via `calculatedType` (which will return the right
    /// value when this is nil, or when we don't want to
    /// animate)
    ///
    /// This is initially set to nil, and halfway
    /// through the reveal animation - if any - it 
    /// will be set to the reveal type.
    @State var type: TileBackgroundType? = nil
    
    @Environment(\.showFocusHint) var showFocusHint: Bool
    
    let letter: String?
    let delay: Int 
    
    /// The background type we wish to reveal with
    /// a "flip" animation (if `animate` is set to true)
    let revealState: TileBackgroundType?
    
    let animate: Bool
    
    let halfDuration = 1.0 / 4.0
    
    @State var scaleSize = CGSize(width: 1.0, height: 1.0)
    let pulseHalfDuration = 0.25 / 4.0
    
    var isEmpty: Bool {
        letter == nil || letter == ""
    }
    
    /// The background type that will be actually used
    /// at a given moment.
    var calculatedType: TileBackgroundType {
        
        if !animate {
            return revealState ?? .maskedFilled
        }
        
        guard let type = self.type else {
            if isEmpty {
                return .maskedEmpty
            } 
            return .maskedFilled
        } 
        
        return type
    }
    
    func fontSize(_ gr: GeometryProxy) -> Double {
        if gr.size.height < 50 {
            // Hardcode some value which is used for
            // small previews (like in a keyboard
            // accessory view)
            return 20
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
        
        return 8
    }
    
    var body: some View {
        GeometryReader { gr in 
            ZStack {
                TileBackgroundView( 
                    type: calculatedType)
                    .animation(nil, value: self.type)
                    .rotation3DEffect(
                        .degrees(rotate + rotateOut), 
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0)
                
                if showFocusHint {
                    // This is the cursor branch.
                    // 
                    // Text() modifiers need to be same
                    // here and in the letter branch
                    // (except animations)
                    Text("_") 
                        .font( 
                            .system(size: fontSize(gr), weight: .bold))
                        .textCase(.uppercase)
                        .padding(padding(gr))
                        .scaledToFit()
                        .minimumScaleFactor(0.19)
                        .lineLimit(1)
                        .foregroundColor(
                            (animate && flip == false) || calculatedType == .maskedFilled ? palette.maskedTextColor : palette.revealedTextColor) 
                            .blinking(duration: 0.5)
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
                        .scaleEffect(CGSize(width: 1.0, height: (flip ? -1.0 : 1.0)))
                        .animation(nil, value: self.flip)
                        .rotation3DEffect(    
                            .degrees(rotate + rotateOut), 
                            axis: (x: 1, y: 0, z: 0),
                            perspective: 0)
                        .foregroundColor(
                            (animate && flip == false) || calculatedType == .maskedFilled ? palette.maskedTextColor : palette.revealedTextColor)  
                }
            } 
        }
        // frame w maxWidth must come before aspectRatio
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        
        // aspectRatio must come after maxWidth
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        
        .frame(maxWidth: sideLength, maxHeight: sideLength)
        .frame(minWidth: 24, minHeight: 24)
        .aspectRatio(1, contentMode: .fit)
        
        .scaleEffect(self.scaleSize)
        
        //        .background(.green)
        
        .animation(
            Animation.easeIn(duration: halfDuration),
            value: self.rotate)
        .animation(
            Animation.easeOut(duration: halfDuration),
            value: self.rotateOut)
        .animation(
            Animation.easeInOut(duration: pulseHalfDuration),
            value: self.scaleSize)
        .onChange(of: self.letter) { new in
            // This animates a small "bulge" animation
            // on receiving input
            guard animate else { return }
            guard self.revealState == nil, new != nil, new != "" else {
                return
            } 
            
            Task {
                defer {
                    self.scaleSize = CGSize(width: 1.0, height: 1.0)
                }
                
                self.scaleSize = CGSize(width: 1.1, height: 1.1)
                try? await Task.sleep(nanoseconds: UInt64(pulseHalfDuration * 500_000_000))
            }
        }
        .task { 
            // This animates the reveal (flip)
            guard animate, let revealState = self.revealState else { return }
            try? await Task.sleep(
                nanoseconds: UInt64(
                    Double(delay) * halfDuration * 500_000_000))
            self.rotate = 90
            try? await Task.sleep(
                nanoseconds: UInt64(halfDuration * 1_000_000_000))
            self.rotateOut = 90
            self.flip = true
            self.type = revealState
        }
    }
}


private struct PaletteKey: EnvironmentKey {
    static let defaultValue: Palette = DarkPalette()
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

struct Tile_Previews: PreviewProvider {
    static let wa = Array("fuels")
    static var previews: some View {
        PaletteSetterView {
            VStack {
            Text("Blinking cursor test")
        Tile(letter: nil, delay: 0, revealState: nil, animate: true).environment(\.showFocusHint, true)
            }
        }
        VStack {
            Text("With animation")
            HStack {
                Tile(letter: "A", delay: 0, revealState: .rightPlace, animate: true)
                Tile(letter: "B", delay: 0, revealState: .wrongPlace, animate: true)
                Tile(letter: "C", delay: 0, revealState: .wrongLetter, animate: true)
            }
            
            Divider()
            
            VStack {
                HStack {
                    Tile(letter: "A", delay: 0, revealState: .rightPlace, animate: false)
                    Tile(letter: "B", delay: 0, revealState: .wrongPlace, animate: false)
                    Tile(letter: "C", delay: 0, revealState: .wrongLetter, animate: false)
                    Tile(letter: "D", delay: 0, revealState: .none, animate: false)
                }.environment(\.palette, LightPalette())
                
            HStack {
                Tile(letter: "A", delay: 0, revealState: .rightPlace, animate: false)
                Tile(letter: "B", delay: 0, revealState: .wrongPlace, animate: false)
                Tile(letter: "C", delay: 0, revealState: .wrongLetter, animate: false)
                Tile(letter: "D", delay: 0, revealState: .none, animate: false)
            }.environment(\.palette, DarkPalette())
        }
            Text("Without animation")
        }
        VStack {
            HStack {
                ForEach(0..<5, id: \.self) { ix in
                    Tile(letter: String(wa[ix]), delay: 0, revealState: .wrongLetter, animate: true)
                }
            }
            
            Row(delayRowIx: 0, model: RowModel(
                word: "fuels",
                expected: "fuels",
                isSubmitted: true))
            
            Tile(letter: "q", delay: 0, revealState: .rightPlace, animate: true) 
                .font(.system(size: 100))
            
            Tile(letter: "q", delay: 1, revealState: .wrongPlace, animate: true)
            Tile(letter: "", delay: 0, revealState: nil, animate: true)
            
            HStack {
                VStack {
                    Tile(letter: "i", delay: 0, revealState: nil, animate: true)
                    Tile(letter: "", delay: 0, revealState: nil, animate: true)
                }
                
                VStack {
                    Tile(letter: "i", delay: 0, revealState: nil, animate: true)
                        .environment(\.palette, LightPalette())
                    Tile(letter: "", delay: 0, revealState: nil, animate: true)
                        .environment(\.palette, LightPalette())
                }
            }
            
            Tile(letter: "X", delay: 0, revealState: .wrongPlace, animate: true)
                .environment(\.palette, LightPalette())
        }
        
        Tile(letter: nil, delay: 0, revealState: nil, animate: true)
        
        HStack() {
            ZStack(alignment: .center) {
//                Tile(letter: " W° ", delay: 0, revealState: .wrongLetter, animate: false)
                TileBackgroundView(type: .rightPlace)
                
                VStack {
                    HStack {
                        Image(systemName: "b.square.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        Image(systemName: "a.square")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                        Image(systemName: "square")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                    }
                    
                    ForEach(0..<2, id: \.self) { _ in 
                        HStack {
                            Image(systemName: "square")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                            Image(systemName: "square")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                            Image(systemName: "square")
                                .font(.system(size: 100))
                                .foregroundColor(.white)
                        }
                    }
                    
//                    Image(systemName: "keyboard")
//                    .font(.system(size: 300))
//                    .foregroundColor(.white)
                    
                }
            }
        }
        .environment(\.palette, DarkHCPalette())
        .environment(\.sideLength, 500)
    }
}
