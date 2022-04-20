import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var activityItems: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    var callback: (()->())
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)
        
        controller.excludedActivityTypes = excludedActivityTypes
        
        updateCallback(controller, callback)
        
        return controller
    }
    
    func updateCallback(
        _ uiViewController: UIActivityViewController, 
        _ callback: @escaping ()->()) {
        uiViewController.completionWithItemsHandler = {
            type, completed, items, error in 
            
            guard completed else {
                return
            }
            
            print("Calling callback")
            callback()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        print("Updating callback")
        updateCallback(uiViewController, self.callback)
    }
}
