//
//  Item.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
