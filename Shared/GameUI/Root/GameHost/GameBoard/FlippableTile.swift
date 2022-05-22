import SwiftUI

extension FlippableTile where Revealed == Tile<InternalFillColor> {
    init(letter: TileModel?, flipped: TileModel?,
         tag: Int, jumpIx: Int?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->(), 
         jumpCallback: @escaping (Int)->(),
         duration: CGFloat,
         jumpDuration: CGFloat) {
        self.letter = letter 
        self.tag = tag 
        self.jumpIx = jumpIx
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.jumpCallback = jumpCallback
        self.duration = duration
        self.jumpDuration = jumpDuration
        
        if let flipped = flipped {
            revealedObject = Tile(model: flipped)
        } else {
            revealedObject = nil
        }
    }
}

struct FlippableTile<Revealed: View>: View {
    let letter: TileModel?

    let tag: Int 
    let jumpIx: Int?
    
    let midCallback: ()->()
    let flipCallback: ()->()
    let jumpCallback: (Int)->()
    
    let duration: CGFloat
    let jumpDuration: CGFloat 
    
    @State var jumping: Bool = false
    
    let revealedObject: Revealed?
    
    var revealConfig: RevealConfig {
        RevealConfig(
            totalDuration: duration,
            maxSteps: 2, 
            callbackStep: 1, 
            callback: midCallback,
            finalCallback: flipCallback)
    }
    
    init(letter: TileModel?, 
         tag: Int, jumpIx: Int?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->(), 
         jumpCallback: @escaping (Int)->(),
         duration: CGFloat,
         jumpDuration: CGFloat,
         revealedObject: ()->Revealed?) 
    {
        self.letter = letter 
        self.tag = tag 
        self.jumpIx = jumpIx
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.jumpCallback = jumpCallback
        self.duration = duration
        self.jumpDuration = jumpDuration
        self.revealedObject = revealedObject()
    }
    
    var body: some View {
        nonJumpingBody
            .jumping(jumping: $jumping, duration: jumpDuration)
            .safeOnChange(of: jumpIx) { nx in
                jumping = (tag == nx)
            }
            .safeOnChange(of: jumping) { nj in 
                if !nj {
                    jumpCallback(tag)
                }
            }
    }
    
    @ViewBuilder
    var nonJumpingBody: some View {
        VStack {
            if revealedObject == nil {
                Tile(model: letter)
            } 
            
            if let revealedObject = revealedObject {
                Tile(model: letter)
                    .modifier(RevealModifier(
                        config: revealConfig, 
                        revealed: {
                            revealedObject
                        }))
            }
        }
    }
}
