import SwiftUI

@main
struct MyApp: App {
    @State var finished = false
    
    @AppStorage("dailyState") 
    var dailyState: DailyState? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var debugMessage: String = ""
    @State var count = 0
    
    @StateObject var gameState: GameState = GameState(expected: "tests") 
    
    @StateObject var validator = WordValidator(name: "en")
    
    var body: some Scene {
        WindowGroup {
            VStack {
                
                if dailyState != nil {
                    GameBoardView(state: gameState)
                    .onCompleted {
                        _ in 
                        
                        finished = true
                    }
                    Text(dailyState?.expected ?? "none")
                    Text(String(describing: gameState.rows[0].revealState(0)))
                    Text(self.debugMessage).id("message")
                    Text("\(self.count)").id("count")
                }
                
                if dailyState == nil {
                    Text("Loading state...").onAppear {
                        guard let dailyState = dailyState else {
                            dailyState = DailyState(expected: validator.todayAnswer)
                            return
                        }
                    }
                }
            }
            .environmentObject(validator)
            .onChange(of: self.dailyState) {
                newState in
                
                if let newState = newState {
                    gameState.expected = newState.expected
                    gameState.rows = newState.rows
                    gameState.id = UUID()
                }
            }
            .onReceive(timer) { _ in
                
                
                guard let dailyState = self.dailyState else {
                    return
                }
                
                count += 1
                debugMessage = "TTL: \(dailyState.remainingTtl) for word: \(dailyState.expected)"
                
                if dailyState.isStale {
                    // TODO: process daily results if needed
                    self.dailyState = DailyState(expected: validator.todayAnswer)
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
