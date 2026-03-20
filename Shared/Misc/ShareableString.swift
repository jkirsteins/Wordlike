import LinkPresentation
import UIKit

class ShareableString: NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        value
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        value
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let res = LPLinkMetadata()
        res.title = (value.split(separator: "\n").dropFirst()).joined(separator: "\n")

        if let img = Bundle.main.icon {
            let imageProvider = NSItemProvider(object: img)
            res.imageProvider = imageProvider
        }

        return res
    }

    let value: String

    init(_ value: String) {
        self.value = value
    }
}
