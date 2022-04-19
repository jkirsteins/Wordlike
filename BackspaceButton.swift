import SwiftUI


struct BackspaceButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette 
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    palette.submitKeyboardFill
                        .adjust(
                            pressed: configuration.isPressed)
                )
            
            configuration.label
                .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

struct BackspaceTile: View {
    let maxSize: CGSize
    
    @EnvironmentObject var game: GameState
    
    func padding(_ gp: GeometryProxy) -> CGFloat {
        let minEdge = max(gp.size.width, gp.size.height)
        
        let div: CGFloat 
        
        if minEdge < 30 {
            return 0
        } 
        else if minEdge < 50 {
            div = 9.0
        } 
        else {
            div = 6.0
        }
        
        return gp.size.height / div
    }
    
    func action() {
        guard !game.isCompleted else {
            return
        }
        
        guard 
            let row = game.rows.first(where: { !$0.isSubmitted }),
            let ix = game.activeIx else {
            // no editable rows
            return 
        }
        
        game.rows[ix] = RowModel(
            word: String(row.word.dropLast()),
            expected: row.expected,
            isSubmitted: row.isSubmitted)
    }
    
    var body: some View {
        Button(action: action, label: {
            GeometryReader { gr in
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "delete.left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Spacer()
                    }
                    Spacer()
                }.padding(padding(gr))
            }
            })
            .disabled(game.isCompleted)
            .buttonStyle(BackspaceButtonStyle())
            .frame(
                maxWidth: maxSize.width, 
                maxHeight: maxSize.height)
    }
}

struct InternalBackspaceTilePreview: View {
    @State var side: CGFloat = 74.0
    let state = GameState(expected: DayWord(word: "fuels", day: 1, locale: "en"))
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
            BackspaceTile(maxSize: 
                            CGSize(width: side, height: side))
                SizeConstrainedKeyboardTile(maxSize: CGSize(width: side, height: side), letter: "W")
            }
            Text(verbatim: "\(side)")
            Slider(value: $side, in: 0.0...200.0)
        }.environmentObject(state)
    }
}

struct BackspaceTile_Previews: PreviewProvider {
    static var previews: some View {
        InternalBackspaceTilePreview()
    }
}
