import SwiftUI

@main
struct MyApp: App {
    @State var finished = false
    
    @AppStorage("dailyState") 
    var dailyState: DailyState? = nil
    
    @AppStorage("stats") 
    var stats: Stats = Stats()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var debugMessage: String = ""
    @State var count = 0
    
    let paceSetter = BucketPaceSetter(
        start: WordValidator.MAR_22_2022, 
        bucket: 30)
    
    @StateObject var validator = WordValidator(name: "en")
    @State var testModel: RowModel = RowModel(expected: "fuels")
    @State var testIsActive: Int? = 0
    var body_test: some Scene {
        WindowGroup {
            EditableRow(delayRowIx: 0, model: $testModel, tag: 0, isActive: $testIsActive)
        }
    }
    
    @StateObject var game: GameState = GameState()
    
    var todayIndex: Int {
        self.paceSetter.turnIndex(at: Date())
    }
    
    func updateFromLoadedState(_ newState: DailyState) {
        debugMessage = "Updating..."
        
        game.expected = DayWord(word: newState.expected, day: todayIndex)
        game.rows = newState.rows
        game.isTallied = newState.isTallied
        game.id = UUID()
        game.initialized = true
        game.date = newState.date
    }
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                VStack {
                    Text(verbatim: "\(todayIndex) (\(validator.answer(at: todayIndex)))")
                    if game.initialized && paceSetter.isFresh(game.date, at: Date()) {
                        GameBoardView(state: game)
                            .onStateChange(edited: { newRows in
                                self.dailyState = DailyState(
                                    expected: dailyState!.expected,
                                    date: dailyState!.date,
                                    rows: newRows,
                                    isTallied: dailyState!.isTallied)
                            }, completed: { 
                                state in
                                
                                stats = stats.update(from: game, with: paceSetter)
                                
                                finished = true
                            })
                        Text(verbatim: "\(game.submittedRows)")
                        Text(dailyState?.expected ?? "none")
                        Text(dailyState?.rows[0].word ?? "none")
                        Text(self.debugMessage).id("message")
                        Text("\(self.count)").id("count")
                    } 
                        
                    
                    if let ds = dailyState, !paceSetter.isFresh(ds.date, at: Date()) {
                        Text("Rummaging in the sack for a new word...")
                    }
                    
                    if dailyState == nil {
                        Text("Initializing state...").onAppear {
                            guard let dailyState = dailyState else {
                                dailyState = DailyState(expected: validator.answer(at: todayIndex))
                                return
                            }
                        }
                    }
                }
                .environmentObject(validator)
                .onAppear {
                    if let newState = self.dailyState {
                        updateFromLoadedState(newState)
                    } 
                }
                .onChange(of: self.dailyState) {
                    newState in
                    
                    if let newState = newState {
                        updateFromLoadedState(newState)
                    }
                }
                .onReceive(timer) { newTime in
                    
                    guard let dailyState = self.dailyState else {
                        return
                    }
                    
                    count += 1
                    debugMessage = "TTL: \(paceSetter.remainingTtl(at: newTime)) (f:\(paceSetter.isFresh(dailyState.date, at: newTime))) for word: \(dailyState.expected)" + "\nWRD: \(validator.answer(at: todayIndex))" + "\nTIX: \(todayIndex)"
                    
                    if !paceSetter.isFresh(dailyState.date, at: newTime) {
                        // TODO: process daily results if needed
                        self.dailyState = DailyState(expected: validator.answer(at: todayIndex))
                    }
                }
                .sheet(isPresented: $finished) {
                    StatsView(stats: stats, state: game)
                }
                .navigationTitle("hello")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: { 
                                finished = true
                            }, 
                            label: {
                                Label(
                                    "Stats", 
                                    systemImage: "chart.bar")
                                    .foregroundColor(
                                        Color(
                                            UIColor.label))
                        }) 
                    }
                }
            }
            
            
            //            VStack {
            //                Text("Above").background(.green)
            //                EditableRow_ForPreview()
            //                Text("Below").background(.red)
            //            }
        }
    }
}
