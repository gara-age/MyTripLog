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

    var imageString : String
    
    init(title: String, startDate: Date,endDate : Date, startTime: Int, endTime: Int, imageString: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.imageString = imageString
    }

   
}
