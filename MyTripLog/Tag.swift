//
//  Tag.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI

// Tag Model
struct Tag: Identifiable, Hashable {
    var id = UUID().uuidString
    var text: String
    var size: CGFloat = 0
    var color: Color {
           let hash = abs(text.hashValue)
           let hue = Double(hash % 100) / 100.0
           return Color(hue: hue, saturation: 0.8, brightness: 0.8)
       }
    var transferableItem: NSItemProvider {
        NSItemProvider(object: text as NSString)
    }
}
