import SwiftUI

fileprivate enum ActiveSheet {
    case stats 
    case help
    case settings
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

struct GameHostView: View {
    
    @State var debugMessage: String = ""
    
    @AppStorage 
    var dailyState: DailyState?
    
    @AppStorage 
    var stats: Stats
    
    @AppStorage 
    var shouldShowHelp: Bool
    
    @State var finished = false
    
    @State var timer = Timer.publish(
        every: 1, 
        on: .main, 
        in: .common).autoconnect()
    
    @StateObject var validator: WordValidator
    @StateObject var game: GameState = GameState()
    
    @Environment(\.paceSetter) var paceSetter: PaceSetter
    @Environment(\.debug) var debugViz: Bool
    @Environment(\.palette) var palette: Palette
    
    @State fileprivate var activeSheet: ActiveSheet? = nil
    
    let title: String
    let locale: String
    
    /* Propogated via preferences from the underlying EditableRow. */
    @StateObject var toastMessageCenter = ToastMessageCenter()
    
    init(_ name: String) {
        self._validator = StateObject(wrappedValue: WordValidator(name: name))
        
        self._stats = AppStorage(
            wrappedValue: Stats(), 
            "stats.\(name)")
        
        self._dailyState = AppStorage(
            wrappedValue: nil, 
            "turnState.\(name)")
        
        // Showing help should not be dependent
        // on the name (unlike turn state and stats)
        self._shouldShowHelp = AppStorage(
            wrappedValue: true, "shouldShowHelp")
        
        self.locale = name
        title = name.localeDisplayName
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
    
    // Timer sets this to hh:mm:ss until next word
    // TODO: duplicated with StatsView
    @State var nextWordIn: String = "..." 
    
    @ViewBuilder
    var keyboardView: some View {
        if game.expected.locale == "lv" {
            LatvianKeyboardView()
        }
        else if game.expected.locale == "fr" {
            FrenchKeyboardView()
        } else {
            EnglishKeyboardView()
        }
    }
    
    func recalculateNextWord() {
        let remaining = paceSetter.remainingTtl(at: Date())
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        guard let formatted = formatter.string(from: TimeInterval(remaining)) else {
            nextWordIn = "?"
            return
        }
        nextWordIn = formatted
    }
    
    // When to clear message toast
    @State var clearToastAt: Date? = nil
    
    var body: some View {
        ZStack {
            VStack { 
                Spacer().frame(maxHeight: 24)
                if game.initialized && paceSetter.isFresh(game.date, at: Date()) {
                    GameBoardView(state: game,
                                  canBeAutoActivated: !finished && !shouldShowHelp)
                        .onStateChange(edited: { newRows in
                            self.dailyState = DailyState(
                                expected: dailyState!.expected,
                                date: dailyState!.date,
                                rows: newRows,
                                isTallied: dailyState!.isTallied)
                        }, 
                                       earlyCompleted: {
                            newState in
                            
                            if let dailyState = self.dailyState {
                                if !dailyState.isTallied {
                                    /* Game has just been
                                     completed, so
                                     we can show some messages while
                                     the tiles are finishing animating. */
                                    
                                    if !newState.isWon {
                                        // When losing, show the word
                                        toastMessageCenter.set(dailyState.expected)
                                    } else {
                                        // When winning, show a flavor message
                                        let message: String?
                                        
                                        switch (newState.submittedRows) {
                                        case 6: message = "Phew!"
                                        case 5: message = "Great"
                                        case 4: message = "Splendid"
                                        case 3: message = "Impressive"
                                        case 2: message = "Magnificent"
                                        case 1: message = "Genius"
                                        default:
                                            message = nil
                                        }
                                        
                                        if let message = message {
                                            toastMessageCenter.set(message)
                                        }
                                    }
                                }
                            }
                        },
                                       completed: { 
                            state in
                            
                            if let dailyState = self.dailyState {
                                self.dailyState = DailyState(expected: dailyState.expected, date: dailyState.date, rows: dailyState.rows, isTallied: true)
                            }
                            
                            stats = stats.update(from: game, with: paceSetter)
                            
                            finished = true
                        })
                    
                    if debugViz {
                        Text(verbatim: "\(game.submittedRows)")
                        Text(verbatim: "\(game.isCompleted)")
                        Text(dailyState?.expected ?? "none")
                        Text(dailyState?.rows[0].word ?? "none")
                        Text(self.debugMessage).id("message")
                    }
                    
                    keyboardView
                        .environmentObject(game)
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
            .environmentObject(toastMessageCenter)
            .environment(\.keyboardHints, game.keyboardHints)
            .environmentObject(validator)
            .onAppear {
                if shouldShowHelp {
                    activeSheet = .help
                }
                
                if let newState = self.dailyState {
                    updateFromLoadedState(newState)
                } 
            }
            .onChange(of: self.toastMessageCenter.message ) {
                newMessage in 
                
                self.clearToastAt = Date() + 2.0
            }
            .onChange(of: self.dailyState) {
                newState in
                
                if let newState = newState {
                    updateFromLoadedState(newState)
                }
            }
            .onReceive(timer) { newTime in
                
                recalculateNextWord()
                
                
                if let clearToastAt = clearToastAt, Date() > clearToastAt {
                    self.clearToastAt = nil
                    withAnimation {
                        self.toastMessageCenter.message = nil
                    }
                }
                
                guard let dailyState = self.dailyState else {
                    return
                }
                
                debugMessage = "TTL: \(paceSetter.remainingTtl(at: newTime)) (f:\(paceSetter.isFresh(dailyState.date, at: newTime))) for word: \(dailyState.expected)" + "\nTIX: \(todayIndex)" + "\nTALLIED: \(self.dailyState?.isTallied ?? false)" + "\nPS: \(paceSetter)" + "\nSSH: \(shouldShowHelp)"
                
                if !paceSetter.isFresh(dailyState.date, at: newTime) {
                    // TODO: process daily results if needed
                    self.dailyState = DailyState(expected: validator.answer(at: todayIndex))
                }
            }
            .sheet(item: $activeSheet, 
                   onDismiss: {
                
                // assuming this is the first
                // sheet to ever be dismissed
                if shouldShowHelp {
                    shouldShowHelp = false
                }
                
            }) { item in
                PaletteSetterView {
                    switch (item) {
                    case .help:
                        HelpView().padding(16)
                    case .stats:
                        StatsView(stats: stats, state: game)
                    case .settings:
                        SettingsView()
                    }    
                }
            }
            .onChange(of: finished) {
                newF in 
                if (newF && activeSheet == nil) {
                    activeSheet = .stats
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: { 
                            activeSheet = .help
                        }, 
                        label: {
                            Label(
                                "Help", 
                                systemImage: "questionmark.circle")
                                .foregroundColor(
                                    Color(
                                        UIColor.label))
                        })  
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { 
                            activeSheet = .stats
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { 
                            activeSheet = .settings
                        }, 
                        label: {
                            Label(
                                "Help", 
                                systemImage: "gear")
                                .foregroundColor(
                                    Color(
                                        UIColor.label))
                        })  
                }
            }
            .padding(8)
            .frame(maxHeight: 650)
            
            if let toastMessage = toastMessageCenter.message {
                VStack {
                    Spacer().frame(maxHeight: 48)
                    Text(verbatim: "\(toastMessage.message)")
                        .foregroundColor(palette.toastForeground)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(palette.toastBackground))
                    Spacer()
                }
                .transition(.opacity)
            }
        }
    }
}

struct GameHostView_Previews: PreviewProvider {
    static var previews: some View {
        GameHostView("en")
        GameHostView("fr")
        GameHostView("lv")
    }
}
