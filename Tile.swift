import SwiftUI

struct Tile: View {
    @State var rotate: Double = 0
    @State var rotateOut: Double = 0
    
    @State var flip = false
    @State var type: TileBackgroundType = .maskedEmpty
    
    let letter: String?
    let delay: Int 
    let revealState: TileBackgroundType?
    
    let halfDuration = 1.0 / 2.0
    
    @State var scaleSize = CGSize(width: 1.0, height: 1.0)
    let pulseHalfDuration = 0.25 / 2.0
    
    var body: some View {
        ZStack {
            TileBackgroundView( 
                type: type)
                .animation(nil, value: self.type)
                .rotation3DEffect(
                    .degrees(rotate + rotateOut), 
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0)
            
            if let letter = letter {
                Text(letter) 
                //                    .padding(8)
                    .font(.system(size: 200))
                    .textCase(.uppercase)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .scaleEffect(CGSize(width: 1.0, height: (flip ? -1.0 : 1.0)))
                    .animation(nil, value: self.flip)
                    .rotation3DEffect(    
                        .degrees(rotate + rotateOut), 
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0)
                    .foregroundColor(.white)  
            }
        } 
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 150)
        
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
                print("Not scaling", new)
                return
            } 
            
            print("Scaling from", new)
            
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
    static var previews: some View {
        VStack {
            Tile(letter: "q", delay: 0, revealState: .rightPlace)
            Tile(letter: "q", delay: 1, revealState: .wrongPlace)
            Tile(letter: "q", delay: 0, revealState: nil)
            Tile(letter: "", delay: 0, revealState: nil)
        }
        .environment(\.palette, DarkPalette())
    }
}
