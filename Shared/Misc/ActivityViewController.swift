#if os(iOS)
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var activityItems: [UIActivityItemSource]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    var callback: () -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>)
        -> UIActivityViewController
    {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        controller.excludedActivityTypes = excludedActivityTypes

        updateCallback(controller, callback)

        return controller
    }

    func updateCallback(
        _ uiViewController: UIActivityViewController,
        _ callback: @escaping () -> Void
    ) {
        uiViewController.completionWithItemsHandler = {
            _, completed, _, _ in
            guard completed else {
                return
            }

            callback()
        }
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) {
        updateCallback(uiViewController, callback)
    }
}
#endif
