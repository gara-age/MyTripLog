//
//  scheduleTag.swift
//  MyTripLog
//
//  Created by 최민서 on 2/25/24.
//

import Foundation
import SwiftData

@Model
class ScheduleTag : Identifiable {
    
        var travelTitle: String
        var dayIndex : Int
        var index : Int
        var tagColor : String
        var tagText : String
        var tagHeight : CGFloat
    
    var travel: Travel?
    
    init(travelTitle: String, dayIndex: Int, index: Int, tagColor: String, tagText: String, tagHeight: CGFloat, travel: Travel? = nil) {
        self.travelTitle = travelTitle
        self.dayIndex = dayIndex
        self.index = index
        self.tagColor = tagColor
        self.tagText = tagText
        self.tagHeight = tagHeight
        self.travel = travel
    }
}
