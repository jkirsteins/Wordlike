import SwiftUI

@main
struct MyApp: App {
    @State var finished = false
    
    var body: some Scene {
        WindowGroup {
            GameBoardView(state: GameState(expected: "board")).onCompleted {
                _ in 
                
                finished = true
            }.sheet(isPresented: $finished) {
                Text("Done")
            }

//            VStack {
//                Text("Above").background(.green)
//                EditableRow_ForPreview()
//                Text("Below").background(.red)
//            }
        }
    }
}
