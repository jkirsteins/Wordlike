import SwiftUI

struct LatvianKeyboard_Simplified: View {
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
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "E")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "R")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "T")
                }
                
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "U")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "I")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "O")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "P")
                }
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeSettingKeyboardButton(
                        maxSize: $maxSize, letter: "A")
                    KeyboardButton(letter: "S")
                    KeyboardButton(letter: "D")
                    KeyboardButton(letter: "F")
                    KeyboardButton(letter: "G")
                }
                Group {
                    KeyboardButton(letter: "H")
                    KeyboardButton(letter: "J")
                    KeyboardButton(letter: "K")
                    KeyboardButton(letter: "L")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Z")
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
                SubmitButton<SimplifiedLatvianWordValidator>(maxSize: wideSize)
            }
        }
    }
}
