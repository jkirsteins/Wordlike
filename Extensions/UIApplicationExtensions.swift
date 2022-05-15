import SwiftUI

class GlobalTapDelegate: NSObject, UIGestureRecognizerDelegate {
    let requestCount: Binding<Int>
    
    init(_ requestCount: Binding<Int>) {
        self.requestCount = requestCount
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        requestCount.wrappedValue += 1
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIApplication {
    func addGestureRecognizer(_ d: GlobalTapDelegate) {
        let sceneWindows =
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
        
        guard let window = sceneWindows?.first else { return }
        let gesture = UITapGestureRecognizer(target: window, action: nil)
        gesture.requiresExclusiveTouchType = false
        gesture.cancelsTouchesInView = false
        gesture.delegate = d
        window.addGestureRecognizer(gesture)
    }
}
