import SwiftUI

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Row(model: RowModel(word: "Hello", expected: "Hella", isSubmitted: true))
            EditableRow(expected: "fuels")
        }
            .environment(\.palette, 
                          colorScheme == .dark ? DarkPalette() : DarkPalette())
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Text("Hello")
                GameBoardView()
                    .navigationTitle("French")
            }
        }
    }
}
