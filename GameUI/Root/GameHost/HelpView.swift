import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Guess the daily word in 6 tries.")
                    .fixedSize(horizontal: false, vertical: true)
                Text("Each guess must be a valid five-letter word.")
                    .fixedSize(horizontal: false, vertical: true)
                Text("After each guess, the color of the tiles will change to show you how close your guess was to the word.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            Text("Examples").fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Tile("w", .rightPlace)
                    Tile("e")
                    Tile("a")
                    Tile("r")
                    Tile("y")
                }
                Text("The letter **W** is in the word and in the correct spot.")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Tile("p")
                    Tile("i", .wrongPlace)
                    Tile("l")
                    Tile("l")
                    Tile("s")
                }
                Text("The letter **I** is in the word but in a different spot.")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Tile("v")
                    Tile("a")
                    Tile("g")
                    Tile("u", .wrongLetter)
                    Tile("e")
                }
                Text("The letter **U** is not in the word in any spot.")
            }
            
            Divider()
            
            Text("A new word is available every day.").fontWeight(.bold)
        }
        .navigationTitle("How to play")
    }
    
    struct HelpView_Previews: PreviewProvider {
        static var previews: some View {
            PaletteSetterView {
                HelpView()
            }
            
            ForEach(AppView_Previews.configurations) {
                MockDevice(config: $0) {
                    PaletteSetterView {
                        HelpView()
                    }
                }
            }
            
            VStack {
                Text("Testing help is scrollable (and doesn't compress text)").frame(minHeight: 200)
                HelpView()
            }
        }
    }
}
