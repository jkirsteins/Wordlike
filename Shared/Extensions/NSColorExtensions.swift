//
//  NSColorExtensions.swift
//  SimpleWordGame (macOS)
//
//  Created by Janis Kirsteins on 20/05/2022.
//

import AppKit

extension NSColor {
    static var label: NSColor {
        NSColor.labelColor
    }
    
    static var secondaryLabel: NSColor {
        NSColor.secondaryLabelColor
    }
    
    static var systemFill: NSColor {
        NSColor.controlBackgroundColor
    }
    
    static var systemBackground: NSColor {
        NSColor.windowBackgroundColor
    }
}
