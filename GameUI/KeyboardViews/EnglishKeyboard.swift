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
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "Q")
                    
                    KeyboardButton(letter: "W")
                    KeyboardButton(letter: "E")
                    KeyboardButton(letter: "R")
                    KeyboardButton(letter: "T")
                }
                
                Group {
                    KeyboardButton(letter: "Y")
                    KeyboardButton(letter: "U")
                    KeyboardButton(letter: "I")
                    KeyboardButton(letter: "O")
                    KeyboardButton(letter: "P")
                }
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "A")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "S")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "D")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "F")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "G")
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "H")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "J")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "K")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "L")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Z")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "X")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "C")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "V")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "B")
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "N")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "M")
                }
                SubmitButton(maxSize: wideSize)
            }
        }
    }
}

struct EnglishKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: "en"))
    
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



