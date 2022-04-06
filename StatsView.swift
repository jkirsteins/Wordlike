import SwiftUI

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
    
    // For sizing the horizontal stats bars
    @State var maxBarWidth: CGFloat = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.palette) var palette: Palette
    
    @State var nextWordIn: String = "..."
    
    func recalculateNextWord() {
        let remaining = Date().secondsUntilTheNextDay
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
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Statistics")
                    .font(Font.system(.title).smallCaps())
                
                HStack(alignment: .top) {
                    VStack {
                        Text("\(stats.played)").font(.largeTitle)
                        Text("Played")
                            .font(.caption)
                            .frame(maxWidth: 50)
                    }
                    VStack {
                        if stats.played == 0 {
                            Text("-").font(.largeTitle)
                        } else {
                        Text("\(Double(stats.won) / Double(stats.played) * 100, specifier: "%.0f")").font(.largeTitle)
                        }
                        Text("Win %")
                            .font(.caption)
                            .frame(maxWidth: 50)
                    }
                    VStack {
                        Text("\(stats.streak)").font(.largeTitle)
                        Text("Current Streak")
                            .font(.caption)
                            .frame(maxWidth: 50)
                    }
                    VStack {
                        Text("\(stats.maxStreak)").font(.largeTitle)
                        Text("Max Streak")
                            .font(.caption)
                            .frame(maxWidth: 50)
                    }
                }.multilineTextAlignment(.center)
            }
            
            VStack(spacing: 8) { 
                Text("Guess Distribution")
                    .font(Font.system(.title).smallCaps())
                
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
                                        (rowIx == stats.maxRow ? palette.rightPlaceFill : palette.wrongLetterFill).preference(
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
                    
                HStack(spacing: 16) {
                    VStack() {
                        Text("Next word")
                            .font(Font.system(.title).smallCaps())
                        Text(nextWordIn)
                            .font(.largeTitle)
                            .onReceive(timer) {
                                _ in 
                                
                                self.recalculateNextWord()
                            }
                            .onAppear {
                                recalculateNextWord()
                            }
                    }.frame(minWidth: 150)
                    
                    Divider().frame(maxHeight: 88)
                    
                    Button(action: {
                        print("sharing...")
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
            .onPreferenceChange(WidthKey.self) {
                newWidth in 
                self.maxBarWidth = newWidth
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
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
                ]))
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
                ]))
        }
        
        PaletteSetterView {
            StatsView(stats: Stats(
                played: 1, 
                won: 1,
                maxStreak: 1,
                streak: 1,
                guessDistribution: [
                    1, 
                    0,
                    0,
                    0,
                    0,
                    0
                ]))
        }
    }
}
