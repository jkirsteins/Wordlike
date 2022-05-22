//
//  SafeMisc.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI

extension View {
    func safeTint(_ tint: Color) -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(self.tint(tint))
        } else {
            return AnyView(self)
        }
    }
}
