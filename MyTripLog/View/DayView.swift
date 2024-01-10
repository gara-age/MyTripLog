//
//  DayView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/10/24.
//

import SwiftUI

struct DayView: View {
    
    var body: some View {
        NavigationStack{
            Text("1일차")
            
            Spacer()
            
            
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }

}

#Preview {
    DayView()
}
