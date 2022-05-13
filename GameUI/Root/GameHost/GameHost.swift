import SwiftUI

fileprivate enum ActiveSheet {
    case stats 
    case help
    case settings
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

/// Represents a game of a given languages, with its
/// own stats separate from other games.
struct GameHost: View {
    
    @AppStorage 
    var dailyState: DailyState?
    
    @AppStorage 
    var stats: Stats
    
    @AppStorage 
    var shouldShowHelp: Bool
    
    @State var timer = Timer.publish(
        every: 1, 
        on: .main, 
        in: .common).autoconnect()
    
    @StateObject var validator: WordValidator
    @StateObject var game: GameState = GameState()
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    @Environment(\.debug) var debugViz: Bool
    @Environment(\.palette) var palette: Palette
    
    @State fileprivate var activeSheet: ActiveSheet? = nil
    
    let locale: GameLocale
    let title: String
    
    /* Propogated via preferences from the underlying EditableRow. */
    @StateObject var toastMessageCenter = ToastMessageCenter()
    
    init(_ locale: GameLocale, seed: Int? = nil) {
        self.init(
            locale, 
            validator: WordValidator(
                locale: locale,
                seed: seed)
        )
    }
    
    fileprivate init(_ locale: GameLocale, validator: WordValidator) {
        self._validator = StateObject(
            wrappedValue: validator)
        
        self._stats = AppStorage(
            wrappedValue: Stats(), 
            "stats.\(locale.fileBaseName)")
        
        self._dailyState = AppStorage(
            wrappedValue: nil, 
            "turnState.\(locale.fileBaseName)")
        
        // Showing help should not be dependent
        // on the name (unlike turn state and stats)
        self._shouldShowHelp = AppStorage(
            wrappedValue: true, "shouldShowHelp")
        
        self.locale = locale 
        title = locale.localeDisplayName
    }
    
    /// Index of current turn (at time of invocation)
    var turnIndex: Int {
        self.turnCounter.turnIndex(at: Date())
    }
    
    func updateFromLoadedState(_ newState: DailyState) {
        game.expected = TurnAnswer(
            word: newState.expected, 
            day: turnIndex,
            locale: self.locale,
            validator: self.validator)
        game.rows = newState.rows
        game.isTallied = newState.state.isTallied
        game.id = UUID()
        game.initialized = true
        game.date = newState.date
        
        self.keyboardHints = safeComputeKeyboardHints()
    }
    
    // Timer sets this to hh:mm:ss until next word
    // TODO: duplicated with StatsView
    @State var nextWordIn: String = "..."
    
    @Environment(\.rootGeometry) var geometry: GeometryProxy?
    
    @ViewBuilder
    var keyboardView: some View {
        switch(locale) {
        case .lv_LV(simplified: true):
            LatvianKeyboard_Simplified()
        case .lv_LV(simplified: false):
            LatvianKeyboard()
        case .fr_FR:
            FrenchKeyboard() 
        default:
            EnglishKeyboard()
        }
    }
    
    func recalculateNextWord() {
        let remaining = turnCounter.remainingTtl(at: Date())
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
    
    /// When to clear message toast
    @State var clearToastAt: Date? = nil
    
    /// When this changes, we want to become
    /// first responder (e.g. on a tap anywhere in the
    /// window)
    @Environment(\.globalTapCount)
    var globalTapCount: Binding<Int>
    
    @Environment(\.rootGeometry) var rootGeometry: GeometryProxy?
    
    /* Sometimes the view appears to go out of bounds of
     the screen. Sometimes after rotation (on a device),
     or (in Swift Playgrounds) when first opening the LV view. 
     
     The rootGeometry proxy should communicate our bounds,
     so we can set that as the max.
     
     Not clear if this definitively solves the issue, but
     the problem seems to be less prevalent.*/
    var body: some View  {
        ZStack(alignment: .top) {
            VStack(alignment: .center) {
                Spacer()
                bodyUnconstrained
                Spacer()
            }
            /* Without `maxWidth: .infinity`, the content 
             might not be wide enough to fill 
             the available space.
             
             So e.g. messages might appear off-center.*/
            .frame(maxWidth: .infinity)
            .border(debugViz ? .red : .clear)
            
            /* Toast message comes second, so it
             shows on top of the content. */
            if let toastMessage = toastMessageCenter.message {
                VStack {
                    Spacer().frame(maxHeight: 24)
                    Text(verbatim: "\(toastMessage.message)")
                        .foregroundColor(palette.toastForeground)
                        .fontWeight(.bold)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(palette.toastBackground))
                }
                .transition(.opacity)
                .padding()
                .border(debugViz ? .red : .clear)
            }
        }
        .environment(\.gameLocale, locale)
    }
    
    /// This is called when a row was edited/submitted
    func turnStateChanged(_ newRows: [RowModel]) {
        let newState: DailyState.State
        switch (dailyState!.state) {
        case .unknown, .notStarted:
            newState = .inProgress
        default:
            newState = dailyState?.state ?? .inProgress
        }
        
        self.dailyState = DailyState(
            expected: dailyState!.expected,
            date: dailyState!.date,
            rows: newRows,
            state: newState)
    }
    
    /// This is called after the turn is finished, and after
    /// all the tile flip animations have completed.
    ///
    /// This is called even if we just opened a previously
    /// finished turn.
    func turnCompletedAfterAnimations(_ state: GameState) {
        if let dailyState = self.dailyState {
            self.dailyState = DailyState(
                expected: dailyState.expected, 
                date: dailyState.date, 
                rows: dailyState.rows, 
                state: .finished(
                    isTallied: true, 
                    isWon: state.isWon)
            )
        }
        
        stats = stats.update(from: game, with: turnCounter)
        
        activeSheet = .stats
    }
    
    /// This is called when a turn is finished. It is called
    /// immediately, while there might still be tiles
    /// animating.
    ///
    /// This will ONLY be called if the game was just
    /// finished. Previously finished and restored states
    /// will not call this.
    func turnCompletedBeforeAnimations(_ newState: GameState) {
        if let dailyState = self.dailyState {
            if !dailyState.state.isTallied {
                /* Game has just been
                 completed, so
                 we can show some messages while
                 the tiles are finishing animating. */
                
                if !newState.isWon {
                    // When losing, show the word
                    toastMessageCenter.set(dailyState.expected.displayValue)
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
    }
    
    /// Removes logic from the UI hierarchy
    var turnDataToDisplay: GameState? {
        if game.initialized && turnCounter.isFresh(
            game.date, at: Date()) {
            return game 
        }
        
        return nil 
    }
    
    @State var keyboardHints = KeyboardHints()
    
    /// If we haven't set the right validator in GameState,
    /// we should not attempt to calculate KeyboardHints yet
    func safeComputeKeyboardHints() -> KeyboardHints {
        guard let safeGame = turnDataToDisplay else {
            return KeyboardHints(
                hints:
                    Dictionary<CharacterModel, TileBackgroundType>(), 
                locale: game.expected.locale)
        }
        
        return safeGame.keyboardHints
    }
    
    @ViewBuilder
    var bodyUnconstrained: some View {
        VStack { 
            if let game = turnDataToDisplay {
                ZStack {
                    /// Allow input from keyboard
                    /// on iPad and macOS
                    ///
                    /// Put behind other views to not
                    /// obscure input (that can break
                    /// context menus e.g.)
                    HardwareKeyboardInput(
                        focusRequests: globalTapCount)
                        .border(debugViz ? .red : .clear)
                    
                    GameBoard(
                        state: game,
                        earlyCompleted: turnCompletedBeforeAnimations,
                        completed: turnCompletedAfterAnimations
                    )
                        .onChange(of: game.rows, perform: turnStateChanged)
                        .contentShape(Rectangle())
                }
                /// For the KeyboardInput view
                .environmentObject(game)
                
                if debugViz {
                    Text(dailyState?.expected.displayValue ?? "none")
                }
                
                keyboardView
                    .environmentObject(game)
                    .environment(
                        \.keyboardSubmitEnabled,
                         validator.ready)
            } 
            
            if 
                (turnDataToDisplay == nil && dailyState == nil) ||
                    (dailyState != nil && !turnCounter.isFresh(dailyState!.date, at: Date())) {
                Text("Rummaging in the sack for a new word...")
                    .multilineTextAlignment(.center)
                    .border(debugViz ? .red : .clear)
            }
            
            if 
                dailyState == nil,
                // Answer can be nil if validator is not
                // ready yet
                    let answer = validator.answer(
                        at: turnIndex) 
            {
                Text("Initializing state...").onAppear {
                    guard let _ = dailyState else {
                        self.dailyState = DailyState(expected: answer)
                        return
                    }
                }
            }
        }
        .border(debugViz ? .yellow : .clear)
        .task {
            let seed = validator.seed 
            let locale = validator.locale
            
            DispatchQueue.global(qos: .userInitiated).async {
                let a = WordValidator.loadAnswers(
                    seed: seed, 
                    locale: locale)
                let gt = WordValidator.loadGuessTree(locale: locale)
                
                DispatchQueue.main.async {
                    validator.initialize(answers: a, guessTree: gt)
                }
            }
        }
        .environmentObject(toastMessageCenter)
        .environment(
            \.keyboardHints, keyboardHints)
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
            
            if
                // Answer might not be available before
                // validator has initialized
                let answer = validator.answer(at: turnIndex),
                !turnCounter.isFresh(dailyState.date, at: newTime) 
            {
                stats = stats.update(from: game, with: turnCounter)
                self.dailyState = DailyState(expected: answer)
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
        }
    }
}

struct GameHostView_Previews: PreviewProvider {
    static var previews: some View {
        GameHost(.en_US)
        GameHost(.fr_FR)
        GameHost(.lv_LV(simplified: true))
        GameHost(.lv_LV(simplified: false))
    }
}
