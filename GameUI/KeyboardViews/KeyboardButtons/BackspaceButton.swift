import SwiftUI

fileprivate struct BackspaceButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette 
    
    @EnvironmentObject var game: GameState
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    palette.normalKeyboardFill
                        .adjust(
                            pressed: configuration.isPressed)
                )
            
            configuration.label
                .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

/// Button to delete characters.
struct BackspaceButton: View {
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
        self.game.deleteBackward()
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

struct InternalBackspaceButtonPreview: View {
    @State var side: CGFloat = 74.0
    let state = GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: "en", validator: WordValidator(name: "en")))
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
            BackspaceButton(maxSize: 
                            CGSize(width: side, height: side))
                SizeConstrainedKeyboardButton(maxSize: CGSize(width: side, height: side), letter: "W")
            }
            Text(verbatim: "\(side)")
            Slider(value: $side, in: 0.0...200.0)
        }.environmentObject(state)
    }
}

struct BackspaceButton_Previews: PreviewProvider {
    static var previews: some View {
        InternalBackspaceButtonPreview()
    }
}
