//
//  SafeLabel.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI

struct SafeLabel: View {
    let text: String
    let systemImage: String
    
    init(_ text: String, systemImage: String) {
        self.text = text
        self.systemImage = systemImage
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            Label(text, systemImage: systemImage)
        } else {
            HStack(spacing: GridPadding.normal) {
                Image(systemName: systemImage)
                Text(text)
            }
        }
    }
}
