import SwiftUI

struct EnglishKeyboard: View {
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
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "Q", locale: gameLocale.nativeLocale)
                    
                    KeyboardButton(letter: "W", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "E", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "R", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "T", locale: gameLocale.nativeLocale)
                }
                
                Group {
                    KeyboardButton(letter: "Y", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "U", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "I", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "O", locale: gameLocale.nativeLocale)
                    KeyboardButton(letter: "P", locale: gameLocale.nativeLocale)
                }
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "A", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "S", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "D", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "F", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "G", locale: gameLocale.nativeLocale)
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "H", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "J", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "K", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "L", locale: gameLocale.nativeLocale)
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Z", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "X", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "C", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "V", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "B", locale: gameLocale.nativeLocale)
                }
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "N", locale: gameLocale.nativeLocale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "M", locale: gameLocale.nativeLocale)
                }
                SubmitButton(maxSize: wideSize)
            }
        }
    }
}

struct EnglishKeyboardView_Previews: PreviewProvider {
    static let state = GameState(
        expected: TurnAnswer(word: "fuels", day: 1, locale: .en_US, validator: WordValidator(locale: .en_US)))
    
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
                    ], locale: .en_US))
            }
        }.environmentObject(state)
    }
}



