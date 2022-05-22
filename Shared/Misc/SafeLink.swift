//
//  SafeLink.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 22/05/2022.
//

import SwiftUI

struct SafeLink<LabelView: View>: View {
    let destination: URL
    let label: ()->LabelView
    
    var body: some View {
        if #available(iOS 14.0, *) {
            Link(destination: destination, label: label)
        } else {
            Button(action: {
                   UIApplication.shared.open(destination)
            }, label: label)
        }
    }
}
