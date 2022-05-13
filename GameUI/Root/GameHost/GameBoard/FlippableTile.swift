import SwiftUI

struct FlippableTile: View {
    let letter: TileModel
    let flipped: TileModel?
    
    let midCallback: ()->()
    let flipCallback: ()->()
    
    let duration: CGFloat
    
    init(letter: TileModel, flipped: TileModel?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->()) {
        let duration = CGFloat(0.25)
        self.letter = TileModel(letter: "\(duration)", state: letter.state) 
        self.flipped = flipped 
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.duration = duration
    }
    
    init(letter: TileModel, flipped: TileModel?,
         midCallback: @escaping ()->(),
         flipCallback: @escaping ()->(), duration: CGFloat) {
        self.letter = letter 
        self.flipped = flipped 
        self.midCallback = midCallback
        self.flipCallback = flipCallback
        self.duration = duration
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
        if flipped == nil {
            Tile(model: letter)
        } else if let flipped = flipped {
            Tile(model: letter)
                .modifier(RevealModifier(
                    config: revealConfig, 
                    revealed: {
                        Tile(model: flipped)
                    }))
        }
    }
}
