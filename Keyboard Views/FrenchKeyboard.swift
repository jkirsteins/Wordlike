import SwiftUI

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
                    SizeSettingKeyboardTile(maxSize: $maxSize, letter: "A")
                    
                    KeyboardTile(letter: "Z")
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
            
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Q")
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
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "M")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceTile(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "W")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "X")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "C")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "V")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "B")
                }
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "N")
                }
                SubmitTile(maxSize: wideSize)
            }
            
        }
    }
}

struct FrenchKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: DayWord(word: "aller", day: 1, locale: "fr"))
    
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




