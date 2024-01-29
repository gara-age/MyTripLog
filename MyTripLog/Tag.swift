//
//  Tag.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI

// Tag Model
struct Tag: Identifiable, Hashable , Equatable {
    var id = UUID().uuidString
    var text: String
    var size: CGFloat = 0
    var color: Color 
    var height: CGFloat
    
    var transferableItem: NSItemProvider {
        NSItemProvider(object: text as NSString)
    }
}
