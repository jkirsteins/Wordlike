import SwiftUI

struct EmptyNavWelcomeView: View {
    var body: some View {
        VStack {
            Tiles(
                "WELCOME!", 
                cols: 8, 
                minWidth: 30, 
                maxWidth: 100)

            Text("Select a language in the left side menu to start the game.")
        }
    }
}

struct EmptyNavWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyNavWelcomeView()
    }
}
