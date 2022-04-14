import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to play")
                    .font(Font.system(.title).smallCaps())
                    .fontWeight(.bold)
                Text("Guess the daily word in 6 tries.")
                Text("Each guess must be a valid five-letter word.")
                Text("After each guess, the color of the tiles will change to show you how close your guess was to the word.")
            }
            
            Divider()
            
            Text("Examples").fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Tile(letter: "w", delay: 0, revealState: .rightPlace, animate: false)
                    ForEach(Array("eary"), id: \.self) {
                        (char: Character) in
                        
                        Tile(letter: String(char), delay: 0, revealState: nil, animate: false)
                    }
                }
                Text("The letter **W** is in the word and in the correct spot.")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Tile(letter: "p", delay: 0, revealState: nil, animate: false)
                    Tile(letter: "i", delay: 0, revealState: .wrongPlace, animate: false)
                    ForEach(Array("lls"), id: \.self) {
                        (char: Character) in
                        
                        Tile(letter: String(char), delay: 0, revealState: nil, animate: false)
                    }
                }
                Text("The letter **I** is in the word but in a different spot.")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ForEach(Array("vag"), id: \.self) {
                        (char: Character) in
                        
                        Tile(letter: String(char), delay: 0, revealState: nil, animate: false)
                    }
                    Tile(letter: "u", delay: 0, revealState: .wrongLetter, animate: false)
                    Tile(letter: "e", delay: 0, revealState: nil, animate: false)
                }
                Text("The letter **U** is not in the word in any spot.")
            }
            
            Divider()
            
            Text("A new word is available every day.").fontWeight(.bold)
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteSetterView {
            HelpView()
        }
    }
}
