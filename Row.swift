import SwiftUI

struct Row: View {
    var body: some View {
        HStack {
            Tile(letter: "F", delay: 0)
            Tile(letter: "U", delay: 1)
            Tile(letter: "E", delay: 2)
            Tile(letter: "L", delay: 3)
            Tile(letter: "S", delay: 4)
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        Row()
    }
}
