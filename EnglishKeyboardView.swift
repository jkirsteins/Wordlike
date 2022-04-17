import SwiftUI

struct EnglishKeyboardView: View {
    @State var maxSize: CGSize = .zero
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1)
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*2, height: maxSize.height)
    }
    
    var body: some View {
        VStack(spacing: vspacing) {
            HStack(spacing: hspacing) {
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
            
            HStack(spacing: hspacing ) {
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
            
            HStack(spacing: hspacing) {
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
                SubmitTile(maxSize: CGSize(width: maxSize.width*2, height: maxSize.height))
            }
            
        }
        .frame(maxWidth: 600)
        .border(.green)
    }
}

struct EnglishKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("English keyboard")
            
            PaletteSetterView {
                EnglishKeyboardView()
                    .environment(\.keyboardHints, KeyboardHints(hints: [
                        "W": .wrongPlace,
                        "J": .rightPlace,
                        "W": .wrongLetter,
                        "A": .wrongLetter,
                        "S": .wrongLetter,
                        "D": .wrongLetter,
                    ], locale: "en"))
            }
        }
    }
}



