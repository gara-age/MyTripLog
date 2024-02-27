//
//  Travel.swift
//  MyTripLog
//
//  Created by 최민서 on 2/19/24.
//

import SwiftUI
import SwiftData

@Model
class Travel {
    
    var id: UUID
    @Attribute(.unique) var title: String
    var startDate : Date
    var endDate : Date
    var startTime : Int
    var endTime : Int
    var imageString : String
    
    @Relationship(deleteRule: .cascade, inverse: \Tag.travel)
    var tag: [Tag]?
    
    init(id: UUID = UUID(), title: String, startDate: Date,endDate : Date, startTime: Int, endTime: Int, imageString: String) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.imageString = imageString
    }

   
}
