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
    var date: Date
    var startTime : Int
    var endTime : Int
    
    
    init(title: String, date: Date, startTime: Int, endTime: Int) {
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
    }

   
}
