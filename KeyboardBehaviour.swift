import SwiftUI

import SwiftUI
import Combine

fileprivate extension Notification {
    var keyboardRect: CGRect {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
    }
}

fileprivate extension Publishers {
    static var keyboardRect: AnyPublisher<CGRect, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardRect }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGRect(x: 0, y: 0, width: 0, height: 0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}


/// Wraps an inner editor view and tries to handle keyboard
/// behaviour, so that keyboard avoidance works and content insets
/// are set when needed.
struct KeyboardBehaviour<Content: View> : View
{
    let content: Content
    
    @State var keyboardRect: CGRect = CGRect()
    
    init(@ViewBuilder _ content: ()->Content) {
        self.content = content()
    }
    
    @State var tv: UITextView? = nil
    
    var body: some View {
        return VStack(spacing: 0) {
            content
                .ignoresSafeArea(.keyboard)
        }
        .onReceive(Publishers.keyboardRect) {
            self.keyboardRect = $0
            if let tv = self.tv {
                tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
                tv.scrollIndicatorInsets = tv.contentInset
            }
        }
    }
}

