import SwiftUI

struct Tile: View {
    @Environment(\.palette) var palette: Palette
    
    @State var rotate: Double = 0
    @State var rotateOut: Double = 0
    
    @State var flip = false
    @State var type: TileBackgroundType? = nil
    
    let letter: String?
    let delay: Int 
    let revealState: TileBackgroundType?
    
    let halfDuration = 1.0 / 2.0
    
    @State var scaleSize = CGSize(width: 1.0, height: 1.0)
    let pulseHalfDuration = 0.25 / 2.0
    
    var isEmpty: Bool {
        letter == nil || letter == ""
    }
    
    var calculatedType: TileBackgroundType {
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
                
                if let letter = letter {
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
                            flip == false ? palette.maskedTextColor : palette.revealedTextColor)  
                }
            } 
        }
        // frame w maxWidth must come before aspectRatio
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        
        // aspectRatio must come after maxWidth
        // (otherwise bounds will be off in small environments, e.g. keyboard accessory)
        
        .frame(maxWidth: 150, maxHeight: 150)
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
            guard let revealState = self.revealState else { return }
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
        VStack {
            HStack {
                ForEach(0..<5, id: \.self) { ix in
                    Tile(letter: String(wa[ix]), delay: 0, revealState: .wrongLetter)
                }
            }
            
            Row(model: RowModel(
                word: "fuels",
                expected: "fuels",
                isSubmitted: true))
            
            Tile(letter: "q", delay: 0, revealState: .rightPlace) 
                .font(.system(size: 100))
            
            Tile(letter: "q", delay: 1, revealState: .wrongPlace)
            Tile(letter: "", delay: 0, revealState: nil)
            
            HStack {
                VStack {
                    Tile(letter: "i", delay: 0, revealState: nil)
                    Tile(letter: "", delay: 0, revealState: nil)
                }
                
                VStack {
                    Tile(letter: "i", delay: 0, revealState: nil)
                        .environment(\.palette, LightPalette())
                    Tile(letter: "", delay: 0, revealState: nil)
                        .environment(\.palette, LightPalette())
                }
            }
            
            Tile(letter: "X", delay: 0, revealState: .wrongPlace)
                .environment(\.palette, LightPalette())
        }
    }
}
