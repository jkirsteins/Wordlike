import SwiftUI


struct BackspaceButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette 
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    Color.keyboardFill(
                        for: nil, from: palette)
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
    
    func padding(_ gp: GeometryProxy) -> CGFloat {
        let minEdge = min(gp.size.width, gp.size.height)
        print("--")
        print(minEdge)
        
        let div: CGFloat 
        
        if gp.size.height < 25 {
            return 0
        } else if gp.size.height < 30 {
            return 1
        } else if gp.size.height < 35 {
            return 3
        } else if gp.size.height < 40 {
            return 5
        } else 
        if gp.size.height < 50 {
            div = 6
        } else if gp.size.height < 60 {
            div = 5.0
        } else if gp.size.height < 70 {
            div = 4.5
        } 
        else {
            div = 4.0
        }
        
        return gp.size.height / div
    }
    
    var body: some View {
        Button(action: {
            print("Submitting...")
        }, label: {
            GeometryReader { gr in
//                Text(verbatim: "\(gr.size)")
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Spacer()
                    }
                    Spacer()
                }.padding(padding(gr))
            }
            })
            .buttonStyle(BackspaceButtonStyle())
            .frame(
                maxWidth: maxSize.width, 
                maxHeight: maxSize.height)
    }
}

struct InternalBackspaceTilePreview: View {
    @State var side: CGFloat = 74.0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
            BackspaceTile(maxSize: 
                            CGSize(width: side, height: side))
                SizeConstrainedKeyboardTile(maxSize: CGSize(width: side, height: side), letter: "W")
            }
            Text(verbatim: "\(side)")
            Slider(value: $side, in: 0.0...200.0)
        }
    }
}

struct BackspaceTile_Previews: PreviewProvider {
    static var previews: some View {
        InternalBackspaceTilePreview()
    }
}
