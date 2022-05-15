import SwiftUI

struct FlippableTile: View {
    let letter: TileModel?
    let flipped: TileModel?
    
    let tag: Int 
    let jumpIx: Int?
    
    let midCallback: ()->()
    let flipCallback: ()->()
    let jumpCallback: (Int)->()
    
    let duration: CGFloat
    let jumpDuration: CGFloat 
    
    @State var jumping: Bool = false
    
    init(letter: TileModel?, flipped: TileModel?,
         tag: Int, jumpIx: Int?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->(),
         jumpCallback: @escaping (Int)->()) {
        let duration = CGFloat(0.25)
        self.jumpDuration = 0.25
        self.letter = letter 
        self.flipped = flipped
        self.tag = tag 
        self.jumpIx = jumpIx
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.jumpCallback = jumpCallback
        self.duration = duration
    }
    
    init(letter: TileModel?, flipped: TileModel?,
         tag: Int, jumpIx: Int?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->(), 
         jumpCallback: @escaping (Int)->(),
         duration: CGFloat,
         jumpDuration: CGFloat) {
        self.letter = letter 
        self.flipped = flipped
        self.tag = tag 
        self.jumpIx = jumpIx
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.jumpCallback = jumpCallback
        self.duration = duration
        self.jumpDuration = jumpDuration
    }
    
    var revealConfig: RevealConfig {
        RevealConfig(
            totalDuration: duration,
            maxSteps: 2, 
            callbackStep: 1, 
            callback: midCallback,
            finalCallback: flipCallback)
    }
    
    var body: some View {
        nonJumpingBody
            .jumping(jumping: $jumping, duration: jumpDuration)
            .onChange(of: jumpIx) { nx in
                jumping = (tag == nx)
            }
            .onChange(of: jumping) { nj in 
                if !nj {
                    jumpCallback(tag)
                }
            }
    }
    
    @ViewBuilder
    var nonJumpingBody: some View {
        VStack {
            if flipped == nil {
                Tile(model: letter)
            } 
            
            if let flipped = flipped {
                Tile(model: letter)
                    .modifier(RevealModifier(
                        config: revealConfig, 
                        revealed: {
                            Tile(model: flipped)
                        }))
            }
        }
    }
}
