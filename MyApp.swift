import SwiftUI

@main
struct MyApp: App {
    @State var finished = false
    
    @AppStorage("dailyState") 
    var dailyState: DailyState? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var debugMessage: String = ""
    @State var gameState: GameState? = nil
    
    var body: some Scene {
        WindowGroup {
            VStack {
                
                if gameState != nil {
                    GameBoardView(state: gameState!).onCompleted {
                        _ in 
                        
                        finished = true
                    }
                    Text(dailyState!.expected)
                    Text(gameState!.expected)
                    Text(String(describing: gameState!.rows[0].revealState(0)))
                    Text(self.debugMessage)
                }
                
                if gameState == nil {
                    Text("Loading state...").onAppear {
                        guard let dailyState = dailyState else {
                            dailyState = DailyState()
                            return
                        }
                    }
                }
            }
            .onChange(of: self.dailyState) {
                newState in
                
                if let newState = newState {
                    gameState = GameState(
                        expected: newState.expected,
                        rows: newState.rows)
                }
            }
            .onReceive(timer) { _ in
                
                guard let dailyState = self.dailyState else {
                    return
                }
                
                debugMessage = "TTL: \(dailyState.remainingTtl) for word: \(dailyState.expected)"
                if dailyState.isStale {
                    // TODO: process daily results if needed
                    self.dailyState = DailyState()
                }
            }
            .sheet(isPresented: $finished) {
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
