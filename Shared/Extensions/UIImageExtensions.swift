//
//  UIImageExtensions.swift
//  SimpleWordGame (iOS)
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
