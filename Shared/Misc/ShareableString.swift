//
//  ShareableString.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 21/05/2022.
//

import UIKit
import LinkPresentation

class ShareableString : NSObject, UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        self.value
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        self.value
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata?
    {
        let res = LPLinkMetadata()
        res.title = (self.value.split(separator: "\n").dropFirst()).joined(separator: "\n")
        
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
