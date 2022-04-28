import SwiftUI
import ConfettiView

struct ShareButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    //    let foregroundColor: Color
    //    let isDisabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        return configuration.label
            .padding()
            .foregroundColor(.white)
            .background(configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
        // This is the key part, we are using both an overlay as well as cornerRadius
            .cornerRadius(8)
    }
}

fileprivate struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct StatsView: View {
    let stats: Stats 
    let state: GameState
    
    // For sizing the horizontal stats bars
    @State var maxBarWidth: CGFloat = 0
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.palette) var palette: Palette
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    // Timer sets this to hh:mm:ss until next word
    // TODO: duplicated with GameHostView
    @State var nextWordIn: String = "..."
    
    // For share snippet preparation
    @AppStorage(SettingsView.HARD_MODE_LATVIAN_KEY)
    var isHardMode_Latvian: Bool = false
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    // Share sheet
    @State var isSharing: Bool = false
    @State var shareItems: [Any] = []
    
    /// Recalculate the hh:mm:ss string until next turn
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
    
    var body: some View {
        GeometryReader { gr in 
            ScrollView {
                VStack(spacing: 24) {
                    StatsHeader(
                        stats: stats, 
                        showConfetti: self.state.isWon,
                        showHeader: true)
                    
                    if state.isCompleted {
                        VStack(spacing: 8) {
                            Text("Answer")
                                .font(Font.system(.title).smallCaps())
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(state.expected.word.uppercased())
                                    .font(Font.system(.body))
                                
                                if let defUrl = state.expected.word.definitionUrl(in: state.expected.locale) {
                                    Link("See definition", destination: defUrl)
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 8) { 
                        Text("Guess Distribution")
                            .font(Font.system(.title).smallCaps())
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(0..<6) { rowIx in 
                                    HStack(alignment: .top) {
                                        Text("\(rowIx + 1)")
                                            .padding(2)
                                            .frame(width: 16)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(palette.maskedTextColor)
                                        HStack {
                                            Spacer() 
                                            Text("\(stats.guessDistribution[rowIx])")
                                                .foregroundColor(Color.white)
                                                .fontWeight(.bold)
                                                .font(.body)
                                                .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 4)) 
                                        }.background(
                                            GeometryReader { proxy in
                                                (state.isWon && (rowIx+1) == state.submittedRows ? palette.rightPlaceFill : palette.wrongLetterFill).preference(
                                                    key: WidthKey.self, 
                                                    value: proxy.size.width)
                                            }
                                        )
                                            .frame(maxWidth: 
                                                    
                                                    stats.guessDistribution.contains(where: { $0 > 0 }) ? 
                                                   
                                                   (rowIx == stats.maxRow ? .infinity :  max(24, 
                                                                                             stats.widthRatio(row: rowIx) * maxBarWidth))
                                                   
                                                   : 40
                                                   
                                            )
                                        //.frame(maxWidth: stats.widthRatio(row: rowIx) * maxBarWidth)
                                    }
                                }
                            }
                            if !stats.guessDistribution.contains(where: { $0 > 0 }) {
                                Spacer()
                            }
                        }.padding(24)
                        
                        if state.isCompleted {
                            HStack(spacing: 16) {
                                VStack() {
                                    Text("Next word")
                                        .font(Font.system(.title).smallCaps())
                                    
                                    Text(nextWordIn)
                                        .font(.largeTitle)
                                }.frame(minWidth: 150)
                                
                                Divider().frame(maxHeight: 88)
                                
                                Button(action: {
                                    self.isSharing.toggle()
                                }, label: {
                                    HStack {
                                        Text("Share")
                                            .font(Font.system(.body).smallCaps())
                                            .fontWeight(.bold)
                                        
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }) .buttonStyle(ShareButtonStyle(backgroundColor: palette.rightPlaceFill))
                            }
                        }
                    }
                    .onPreferenceChange(WidthKey.self) {
                        newWidth in 
                        self.maxBarWidth = newWidth
                    } 
                    .sheetWithDetents(
                        isPresented: $isSharing,
                        detents: [.medium(),.large()]) { 
                        } content: {
                            ActivityViewController(activityItems: $shareItems, callback: {
                                isSharing = false
                            })
                        }
                }.onAppear {
                    recalculateNextWord()
                    self.shareItems = [
                        self.state.shareSnippet(
                        hard: self.isHardMode, 
                        additional: self.isHardMode_Latvian ? "*" : nil)
                    ]
                }
                .onReceive(timer) {
                    _ in 
                    
                    self.recalculateNextWord()
                }
                .frame(width: gr.size.width)      
                .frame(minHeight: gr.size.height)
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static let state = GameState(
        initialized: true, 
        expected: TurnAnswer(word: "fuels", day: 2, locale: .en_US), 
        rows: [
            RowModel(word: "clear", expected: "fuels", isSubmitted: true),
            RowModel(word: "duels", expected: "fuels", isSubmitted: true),
            RowModel(word: "fuels", expected: "fuels", isSubmitted: true)
        ],
        isTallied: false,
        date: Date())
    
    static var previews: some View {
        NavigationView {
            PaletteSetterView {
                StatsView(stats: Stats(
                    played: 63, 
                    won: 61,
                    maxStreak: 27,
                    streak: 4,
                    guessDistribution: [
                        1, 
                        3,
                        16,
                        24,
                        11,
                        6
                    ],
                    lastWinAt: nil), state: state)
            }.navigationTitle("Test 1")
        }
        
        PaletteSetterView {
            StatsView(stats: Stats(
                played: 63, 
                won: 61,
                maxStreak: 27,
                streak: 4,
                guessDistribution: [
                    1, 
                    3,
                    16,
                    24,
                    11,
                    6
                ],
                lastWinAt: nil), state: GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: .en_US)))
        }
        
        PaletteSetterView {
            StatsView(stats: Stats(
                played: 0, 
                won: 0,
                maxStreak: 0,
                streak: 0,
                guessDistribution: [
                    0, 
                    0,
                    0,
                    0,
                    0,
                    0
                ],
                lastWinAt: nil), state: GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: .en_US)))
        }
        
        PaletteSetterView {
            StatsView(stats: Stats(
                played: 1, 
                won: 1,
                maxStreak: 1,
                streak: 1,
                guessDistribution: [
                    0, 
                    0,
                    1,
                    0,
                    0,
                    0
                ], 
                lastWinAt: nil), state: state)
        }
    }
}
