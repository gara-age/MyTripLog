//
//  Task.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI

struct Task : Identifiable, Hashable {
    var id : UUID = .init()
    var title : String
    var status : Status
}

enum Status {
    case todo
    case working
    case completed
}
