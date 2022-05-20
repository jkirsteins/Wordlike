//
//  NativeTypes.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import SwiftUI

#if os(iOS)
import UIKit

typealias NativeUserInterfaceSizeClass=UserInterfaceSizeClass
typealias NativeViewRepresentable=UIViewRepresentable
typealias NativeColor=UIColor
typealias NativeImage=UIImage
typealias NativePasteboard=UIPasteboard
#elseif os(macOS)
import AppKit

typealias NativeUserInterfaceSizeClass=MockUserInterfaceSizeClass
typealias NativeViewRepresentable=NSViewRepresentable
typealias NativeColor=NSColor
typealias NativeImage=NSImage
typealias NativePasteboard=NSPasteboard
#endif
