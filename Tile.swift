import SwiftUI

struct Tile: View {
    @State var rotate: Double = 0
    @State var rotateOut: Double = 0
    
    @State var flip = false
    
    @State var type: TileBackgroundType = .maskedEmpty
    
    let letter: String?
    
    let delay: Int
    
    let halfDuration = 1.0 / 2.0
    
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
//        .background(.green)
        
        .animation(
            Animation.easeIn(duration: halfDuration),
            value: self.rotate)
        .animation(
            Animation.easeOut(duration: halfDuration),
            value: self.rotateOut)
        .onAppear {      
            Task {
                try? await Task.sleep(
                    nanoseconds: UInt64(
                        Double(delay) * halfDuration * 500_000_000))
                self.rotate = 90
                try? await Task.sleep(
                    nanoseconds: UInt64(halfDuration * 1_000_000_000))
                self.rotateOut = 90
                self.flip = true
                self.type = .rightPlace
            }
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
            Tile(letter: "q", delay: 0)
            Tile(letter: "q", delay: 1)
        }.environment(\.palette, DarkPalette())
    }
}
