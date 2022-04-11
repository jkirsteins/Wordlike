import SwiftUI

struct GameHostView: View {
    
    @State var debugMessage: String = ""
    
    @AppStorage 
    var dailyState: DailyState?
    
    @AppStorage 
    var stats: Stats 
    
    @State var finished = false
    
    @State var timer = Timer.publish(
        every: 1, 
        on: .main, 
        in: .common).autoconnect()
    
    @StateObject var validator: WordValidator
    @StateObject var game: GameState = GameState()
    
    @Environment(\.paceSetter) var paceSetter: PaceSetter
    
    let title: String
    let locale: String
    
    init(_ name: String) {
        self._validator = StateObject(wrappedValue: WordValidator(name: name))
        
        self._stats = AppStorage(
            wrappedValue: Stats(), 
            "stats.\(name)")
        
        self._dailyState = AppStorage(
            wrappedValue: nil, 
            "turnState.\(name)")
        
        self.locale = name
        
        if name == "en" {
            title = "English"
        } else {
            title = "Français"
        }
    }
    
    var todayIndex: Int {
        self.paceSetter.turnIndex(at: Date())
    }
    
    func updateFromLoadedState(_ newState: DailyState) {
        debugMessage = "Updating..."
        
        game.expected = DayWord(
            word: newState.expected, 
            day: todayIndex,
            locale: self.locale)
        game.rows = newState.rows
        game.isTallied = newState.isTallied
        game.id = UUID()
        game.initialized = true
        game.date = newState.date
        
        
    }
    
    var body: some View {
        VStack {
            Text(verbatim: "\(todayIndex) (\(validator.answer(at: todayIndex)))")
            if game.initialized && paceSetter.isFresh(game.date, at: Date()) {
                GameBoardView(state: game, canBeAutoActivated: !finished)
                    .onStateChange(edited: { newRows in
                        self.dailyState = DailyState(
                            expected: dailyState!.expected,
                            date: dailyState!.date,
                            rows: newRows,
                            isTallied: dailyState!.isTallied)
                    }, completed: { 
                        state in
                        
                        if let dailyState = self.dailyState {
                            self.dailyState = DailyState(expected: dailyState.expected, date: dailyState.date, rows: dailyState.rows, isTallied: true)
                        }
                        
                        stats = stats.update(from: game, with: paceSetter)
                        
                        finished = true
                    })
                Text(verbatim: "\(game.submittedRows)")
                Text(verbatim: "\(game.isCompleted)")
                Text(dailyState?.expected ?? "none")
                Text(dailyState?.rows[0].word ?? "none")
                Text(self.debugMessage).id("message")
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
            
            debugMessage = "TTL: \(paceSetter.remainingTtl(at: newTime)) (f:\(paceSetter.isFresh(dailyState.date, at: newTime))) for word: \(dailyState.expected)" + "\nTIX: \(todayIndex)" + "\nTALLIED: \(self.dailyState?.isTallied ?? false)" + "\nPS: \(paceSetter)"
            
            if !paceSetter.isFresh(dailyState.date, at: newTime) {
                // TODO: process daily results if needed
                self.dailyState = DailyState(expected: validator.answer(at: todayIndex))
            }
        }
        .sheet(isPresented: $finished) {
            PaletteSetterView {
                StatsView(stats: stats, state: game)
            }
        }
        .navigationTitle(title)
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
}

struct GameHostView_Previews: PreviewProvider {
    static var previews: some View {
        GameHostView("en")
        GameHostView("fr")
    }
}
