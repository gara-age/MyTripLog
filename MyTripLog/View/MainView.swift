//
//  MainView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct MainView: View {
    @State private var add : Bool = false
    @State private var searchText  = ""
    @State private var nameText : String = ""
    @State private var startTime : Int = 0
    @State private var endTime : Int = 0

    var body: some View {
        NavigationStack{
            List{
                Section {
                    TravelCardView()
                }
                .frame(height: 130)
                Section {
                    TravelCardView()
                }
                .frame(height: 130)

                Section {
                    TravelCardView()
                }
                .frame(height: 130)

                Section {
                    TravelCardView()
                }
                .frame(height: 130)
                .listRowSeparator(.hidden)
            }
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
                 SetdetailVIew(nameText: $nameText,startTime: $startTime, endTime:$endTime)
             })
             .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("검색"))

        }

    }
}

#Preview {
    MainView()
}
