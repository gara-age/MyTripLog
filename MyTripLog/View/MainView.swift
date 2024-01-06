//
//  MainView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct MainView: View {
    @State private var add : Bool = false
    
    var body: some View {
        NavigationStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle("모든 일정")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            add.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $add, content: {
                    SetdetailVIew()
                })
        }
    }
}

#Preview {
    MainView()
}
