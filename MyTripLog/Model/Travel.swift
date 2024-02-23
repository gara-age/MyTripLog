//
//  Travel.swift
//  MyTripLog
//
//  Created by 최민서 on 2/19/24.
//

import SwiftUI
import SwiftData

@Model
class Travel : Identifiable {
    
    var title: String
    var startDate : Date
    var endDate : Date
    var startTime : Int
    var endTime : Int
//    var dayIndex : Int
//    var index : Int
//    var tagColor : String
//    var tagText : String
//    var tagHeight : Int
    var imageString : String
    
    init(title: String, startDate: Date,endDate : Date, startTime: Int, endTime: Int,/* dayIndex: Int, index : Int,tagColor: String, tagText: String, tagHeight: Int,*/imageString: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
//        self.dayIndex = dayIndex
//        self.index = index
//        self.tagColor = tagColor
//        self.tagText = tagText
//        self.tagHeight = tagHeight
        self.imageString = imageString
    }

   
}
