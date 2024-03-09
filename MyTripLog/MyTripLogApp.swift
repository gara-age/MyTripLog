//
//  MyTripLogApp.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI
import SwiftData

@main
struct MyTripLogApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Travel.self, Tag.self], isAutosaveEnabled: true, isUndoEnabled: true)


    }
}
