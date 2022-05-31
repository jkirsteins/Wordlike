//
//  DoubleExtensions.swift
//  SimpleWordGame (macOS)
//
//  Created by Janis Kirsteins on 31/05/2022.
//

import Foundation

extension Double {
    static func random() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
}
