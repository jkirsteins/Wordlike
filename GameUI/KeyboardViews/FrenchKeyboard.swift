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
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "A", locale: .fr_FR)
                    
                    KeyboardButton(letter: "Z", locale: .fr_FR)
                    KeyboardButton(letter: "E", locale: .fr_FR)
                    KeyboardButton(letter: "R", locale: .fr_FR)
                    KeyboardButton(letter: "T", locale: .fr_FR)
                }
                
                Group {
                    KeyboardButton(letter: "Y", locale: .fr_FR)
                    KeyboardButton(letter: "U", locale: .fr_FR)
                    KeyboardButton(letter: "I", locale: .fr_FR)
                    KeyboardButton(letter: "O", locale: .fr_FR)
                    KeyboardButton(letter: "P", locale: .fr_FR)
                }
            }
            
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Q", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "S", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "D", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "F", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "G", locale: .fr_FR)
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "H", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "J", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "K", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "L", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "M", locale: .fr_FR)
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "W", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "X", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "C", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "V", locale: .fr_FR)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "B", locale: .fr_FR)
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "N", locale: .fr_FR)
                }
                SubmitButton(maxSize: wideSize)
            }
        }
    }
}

struct FrenchKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "aller", day: 1, locale: .fr_FR, validator: WordValidator(locale: .fr_FR)))
    
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
                    ], locale: .fr_FR))
            }
        }.environmentObject(state)
    }
}




