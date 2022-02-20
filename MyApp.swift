import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            GameBoardView(state: GameState(expected: "board"))

//            VStack {
//                Text("Above").background(.green)
//                EditableRow_ForPreview()
//                Text("Below").background(.red)
//            }
        }
    }
}
