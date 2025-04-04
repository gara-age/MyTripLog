//
//  Tag.swift
//  MyTripLog
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI
import SwiftData

@Model
class Tag: Identifiable, Hashable , Equatable {
    var id = UUID().uuidString
    var text: String
    var size: CGFloat?
    var color: String
    var height: CGFloat
    var fontColor : String
    
    var travel: Travel?

    var travelTitle: String?
    var dayIndex : Int?
    var rowIndex : Int?
    var isNotAssigned : Bool?
        
    var transferableItem: NSItemProvider {
        NSItemProvider(object: text as NSString)
    }
    
    init(id: String = UUID().uuidString, text: String, size: CGFloat? = 0, color: String, height: CGFloat, fontColor: String, travel: Travel? = nil, travelTitle: String? = nil, dayIndex: Int? = nil, rowIndex: Int? = nil,isNotAssigned: Bool? = nil) {
        self.id = id
        self.text = text
        self.size = size
        self.color = color
        self.height = height
        self.fontColor = fontColor
        self.travel = travel
        self.travelTitle = travelTitle
        self.dayIndex = dayIndex
        self.rowIndex = rowIndex
        self.isNotAssigned = isNotAssigned
    }

}
class TagManager: ObservableObject {
    @Published var combinedTags: [Tag] = []
    @Published var tags: [Tag] = []

}
