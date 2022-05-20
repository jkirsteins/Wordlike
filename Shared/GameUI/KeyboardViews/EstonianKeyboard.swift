import SwiftUI

/// Estonian keyboard
struct EstonianKeyboard: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessageCenter: ToastMessageCenter
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1) 
    
    var wideSize: CGSize {
        CGSize(
            width: maxSize.width*2 + hspacing, 
            height: maxSize.height)
    }
    
    let locale = Locale.ee_EE
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Q", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "W",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "E",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "R",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "T",
                        locale: locale)
                }
                
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Y", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "U", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "I", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "O", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "P", locale: locale)
                }
            }
            
            RowContainer(spacing: hspacing ) {
                Spacer()
                Group {
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "A", locale: locale)
                    KeyboardButton(letter: "S", locale: locale)
                    KeyboardButton(letter: "D", locale: locale)
                    KeyboardButton(letter: "F", locale: locale)
                    KeyboardButton(letter: "G", locale: locale)
                }
                Group {
                    KeyboardButton(letter: "H", locale: locale)
                    KeyboardButton(letter: "J", locale: locale)
                    KeyboardButton(letter: "K", locale: locale)
                    KeyboardButton(letter: "L", locale: locale)
                    KeyboardButton(letter: "Ö", locale: locale)
                }
                Group {
                    KeyboardButton(letter: "Ä", locale: locale)
                }
                Spacer()
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Z", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "X", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "C", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "V", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "B", locale: locale)
                }
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "N", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "M", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Ü", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Õ", locale: locale)
                }
                
                SubmitButton(maxSize: wideSize)
            }
        }
    }
}

struct EstonianKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: .ee_EE, validator: WordValidator(locale: .ee_EE)))
    
    static var previews: some View {
        GeometryReader { pr in 
            VStack {
                VStack {
                    Text("Estonian keyboard (light)")
                    
                    EstonianKeyboard()
                        .environment(\.keyboardHints, KeyboardHints(hints: [
                            "Q": .wrongPlace,
                            "W": .rightPlace,
                            "E": .wrongLetter,
                        ], locale: .ee_EE))
                        .environment(\.palette, LightPalette())
                }
                
                VStack {
                    Text("Estonian keyboard (light hc)")
                    
                    EstonianKeyboard()
                        .environment(\.keyboardHints, KeyboardHints(hints: [
                            "Q": .wrongPlace,
                            "W": .rightPlace,
                            "E": .wrongLetter,
                        ], locale: .ee_EE))
                        .environment(\.palette, LightHCPalette())
                }
                
                VStack {
                    Text("Estonian keyboard (dark)")
                    
                    EstonianKeyboard()
                        .environment(\.keyboardHints, KeyboardHints(hints: [
                            "Q": .wrongPlace,
                            "W": .rightPlace,
                            "E": .wrongLetter,
                        ], locale: .ee_EE))
                        .environment(\.palette, DarkPalette())
                }
            }
            .environmentObject(state)
            .environment(\.rootGeometry, pr)
        }
    }
}
