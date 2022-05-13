import SwiftUI

struct EnglishKeyboard2: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessage: ToastMessageCenter
    
    @Environment(\.gameLocale)
    var gameLocale: GameLocale
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1)
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*1.5 + hspacing, 
               height: maxSize.height)
    }
    
    let firstRow = [
        "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"
    ]
    let midRow = [
        "A", "S", "D", "F", "G", "H", "J", "K", "L"
    ]
    
    var cols: [GridItem] {
        //        [1,2,3,4,5,6,7,8,9,0]
        [1,2].map { _ in
            GridItem(
                .adaptive(minimum: 20, maximum: 100),
                spacing: 0, 
                alignment: .center)
        }
    }
    
    var body: some View {
        LazyHGrid(rows: cols) {
            LazyHStack(spacing: 0) {
                ForEach(firstRow, id: \.self) { l in
                    Button("\(l)") { 
                        
                    }
                    .frame(
                        minWidth: 20, 
                        idealWidth: 100, 
                        minHeight: 20,
                        idealHeight: 100)
                    .aspectRatio(1, contentMode: .fit)
                    .border(.gray)
                }
            }.border(.green)
            
            LazyHStack(spacing: 0) {
                ForEach(midRow, id: \.self) { l in
                    Button(l) { 
                        
                    }
                    .frame(
                        minWidth: 20, 
                        idealWidth: 100, 
                        minHeight: 20,
                        idealHeight: 100)
                    .aspectRatio(1, contentMode: .fit)
                    .border(.gray)
                }
            }
        }
    }
}

struct EnglishKeyboard2View_Previews: PreviewProvider {
    static let state = GameState(
        expected: TurnAnswer(word: "fuels", day: 1, locale: .en_US, validator: WordValidator(locale: .en_US)))
    
    static var previews: some View {
        VStack {
            Text("English keyboard v2")
            
            EnglishKeyboard2()
                    .border(.red)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .environment(\.keyboardHints, KeyboardHints(hints: [
                        "Q": .wrongPlace,
                        "J": .rightPlace,
                        "W": .wrongLetter,
                        "A": .wrongLetter,
                        "S": .wrongLetter,
                        "D": .wrongLetter,
                    ], locale: .en_US))
        }.environmentObject(state)
    }
}



