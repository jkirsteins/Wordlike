import SwiftUI

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        PaletteSetterView {
            VStack {
                
                EditableRow(expected: "fuels")
                
                Row(model: RowModel(word: "", expected: "Hella", isSubmitted: false))
                Row(model: RowModel(word: "", expected: "Hella", isSubmitted: false))
                Row(model: RowModel(word: "", expected: "Hella", isSubmitted: false))
                Row(model: RowModel(word: "", expected: "Hella", isSubmitted: false))
            }
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView()
    }
}
