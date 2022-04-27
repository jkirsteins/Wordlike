import SwiftUI

/// French keyboard.
struct FrenchKeyboard: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessage: ToastMessageCenter
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1) 
    
    var wideSize: CGSize {
        CGSize(
            width: maxSize.width*2 + hspacing, 
            height: maxSize.height)
    }
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "A")
                    
                    KeyboardButton(letter: "Z")
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
            
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Q")
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
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "M")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "W")
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
                }
                SubmitButton<WordValidator>(maxSize: wideSize)
            }
            
        }
    }
}

struct FrenchKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "aller", day: 1, locale: "fr", validator: WordValidator(name: "fr")))
    
    static var previews: some View {
        VStack {
            Text("French keyboard")
            
            PaletteSetterView {
                FrenchKeyboard()
                    .environment(\.keyboardHints, KeyboardHints(hints: [
                        "A": .wrongPlace,
                        "Z": .rightPlace,
                        "E": .wrongLetter,
                        "R": .wrongLetter,
                        "T": .wrongLetter,
                        "Y": .wrongLetter,
                    ], locale: "fr"))
            }
        }.environmentObject(state)
    }
}




