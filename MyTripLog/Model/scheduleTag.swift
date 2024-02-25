//
//  scheduleTag.swift
//  MyTripLog
//
//  Created by 최민서 on 2/25/24.
//

import Foundation
import SwiftData

@Model
class scheduleTag : Identifiable {
    
        var travelTitle: String
        var dayIndex : Int
        var index : Int
        var tagColor : String
        var tagText : String
        var tagHeight : CGFloat
    
    init(travelTitle: String, dayIndex: Int, index: Int, tagColor: String, tagText: String, tagHeight: CGFloat) {
        self.travelTitle = travelTitle //빌드 오류 발생
        self.dayIndex = dayIndex
        self.index = index
        self.tagColor = tagColor
        self.tagText = tagText
        self.tagHeight = tagHeight
    }
}
