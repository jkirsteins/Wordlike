import SwiftUI

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Row(model: RowModel(word: "Hello", expected: "Hella", isSubmitted: true))
            .environment(\.palette, 
                          colorScheme == .dark ? DarkPalette() : DarkPalette())
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView()
    }
}
