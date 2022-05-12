import SwiftUI

struct FlippableTile: View {
    let letter: TileModel
    let flipped: TileModel?
    
    let flipCallback: ()->()
    let action: ()->()
    
    let delay = CGFloat(2)
    
    var body: some View {
        if flipped == nil {
            Tile(
                letter: letter.letter, 
                delay: Int(delay), 
                revealState: letter.state, 
                animate: false)
        } else if let flipped = flipped {
            Tile(
                letter: letter.letter, 
                delay: Int(delay), 
                revealState: letter.state, 
                animate: false)
                .modifier(
                    RevealModifier(
                        duration: 0.5, 
                        callback: {
                            flipCallback()
                        },
                        revealed: {
                            Tile(
                                letter: flipped.letter, 
                                delay: Int(delay), 
                                revealState: flipped.state, 
                                animate: false)
                        }
                    )
                )
        }
    }
}
