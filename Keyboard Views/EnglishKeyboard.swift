import SwiftUI

struct EnglishKeyboard: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessage: ToastMessageCenter
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1)
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*1.5 + hspacing, 
               height: maxSize.height)
    }
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeSettingKeyboardTile(maxSize: $maxSize, letter: "Q")
                    
                    KeyboardTile(letter: "W")
                    KeyboardTile(letter: "E")
                    KeyboardTile(letter: "R")
                    KeyboardTile(letter: "T")
                }
                
                Group {
                    KeyboardTile(letter: "Y")
                    KeyboardTile(letter: "U")
                    KeyboardTile(letter: "I")
                    KeyboardTile(letter: "O")
                    KeyboardTile(letter: "P")
                }
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "A")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "S")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "D")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "F")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "G")
                }
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "H")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "J")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "K")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "L")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceTile(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Z")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "X")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "C")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "V")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "B")
                }
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "N")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "M")
                }
                SubmitTile(maxSize: wideSize)
            }
        }
    }
}

struct EnglishKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: DayWord(word: "fuels", day: 1, locale: "en"))
    
    static var previews: some View {
        VStack {
            Text("English keyboard")
            
            PaletteSetterView {
                EnglishKeyboard()
                    .environment(\.keyboardHints, KeyboardHints(hints: [
                        "Q": .wrongPlace,
                        "J": .rightPlace,
                        "W": .wrongLetter,
                        "A": .wrongLetter,
                        "S": .wrongLetter,
                        "D": .wrongLetter,
                    ], locale: "en"))
            }
        }.environmentObject(state)
    }
}



