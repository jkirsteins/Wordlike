import SwiftUI

@main
struct MyApp: App {
    @State var finished = false
    
    @AppStorage("dailyState") 
    var dailyState: DailyState? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var debugMessage: String = ""
    @State var count = 0
    
//    @StateObject var gameState: GameState = GameState(expected: "tests") 
    
    @StateObject var validator = WordValidator(name: "en")
    @State var testModel: RowModel = RowModel(expected: "fuels")
    @State var testIsActive: Int? = 0
    var body_test: some Scene {
        WindowGroup {
            EditableRow(delayRowIx: 0, model: $testModel, tag: 0, isActive: $testIsActive)
        }
    }
    
    @StateObject var game: GameState = GameState()
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            VStack {
                Text(verbatim: "\(validator.todayIndex) (\(validator.todayAnswer))")
                if game.initialized && dailyState?.isFresh == true {
                    GameBoardView(state: game)
                        .onStateChange(edited: { newRows in
                            self.dailyState = DailyState(
                                expected: dailyState!.expected,
                                date: dailyState!.date,
                                rows: newRows)
                        }, completed: { 
                        _ in 
                        
                        finished = true
                    })
//                    Text(gameState.expected)
                    Text(dailyState?.expected ?? "none")
                    Text(dailyState?.rows[0].word ?? "none")
                    Text(self.debugMessage).id("message")
                    Text("\(self.count)").id("count")
                } 
                
                if dailyState?.isStale == true {
                    Text("Rummaging in the sack for a new word...")
                }
                
                if dailyState == nil {
                    Text("Initializing state...").onAppear {
                        guard let dailyState = dailyState else {
                            dailyState = DailyState(expected: validator.todayAnswer)
                            return
                        }
                    }
                }
            }
            .environmentObject(validator)
            .onAppear {
                if let newState = self.dailyState {
                    game.expected = newState.expected
                    game.rows = newState.rows
                    game.id = UUID()
                    game.initialized = true
                } 
            }
            .onChange(of: self.dailyState) {
                newState in
                
                if let newState = newState {
                    game.expected = newState.expected
                    game.rows = newState.rows
                    game.id = UUID()
                    game.initialized = true
                }
            }
            .onReceive(timer) { _ in
                
                guard let dailyState = self.dailyState else {
                    return
                }
                
                count += 1
                debugMessage = "TTL: \(dailyState.remainingTtl) for word: \(dailyState.expected)" + "\nAGE: \(dailyState.age)" + "\nWRD: \(validator.todayAnswer)" + "\nTIX: \(validator.todayIndex)"
                
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
