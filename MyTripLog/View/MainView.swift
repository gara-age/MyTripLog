//
//  MainView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query var trips : [Travel]
    @Environment(\.modelContext) private var context
    @State private var add : Bool = false
    @State private var searchText  = ""
    @State private var nameText : String = ""
    @State private var startTime : Int = 0
    @State private var endTime : Int = 0
    @State private var isEditTitle : Bool = false
    @State private var selectedTrip : Travel?
    @State private var deleteRequest = false
    var body: some View {
        NavigationStack{
            List{
                ForEach(trips) { trip in
                    Section{
                        TravelCardView(editTitle: $isEditTitle, trip: trip)
                            .contextMenu{
                                Button {
                                    selectedTrip = trip
                                        editTitle(trip: trip)
                                
                                } label: {
                                    Text("여정명 수정")
                                }
                                Button {
                                    
                                } label: {
                                    Text("PDF로 내보내기")
                                }
                                Button {
                                    
                                } label: {
                                    Text("이미지로 내보내기")
                                }
                                Button {
                                    deleteRequest.toggle()
                                    selectedTrip = trip

                                } label: {
                                    Text("여정 삭제")
                                }
                            }

                            .frame(height: 130)
                            .listRowSeparator(.hidden)
                         
                    }
                              }
                .frame(height: 130)
               
                .listRowSeparator(.hidden)
            }
            .alert("삭제시 복구가 어렵습니다. 정말 삭제하시겠습니까?", isPresented: $deleteRequest) {
                Button(role: .destructive) {
                    withAnimation{
                        if let selectedTrip = selectedTrip {
                            context.delete(selectedTrip)
//                            self.selectedTrip = nil
                        }
                    }
                } label: {
                    Text("삭제")
                }
                
                Button(role: .cancel) {
//                    selectedTrip = nil
                } label: {
                    Text("취소")
                }
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
        .sheet(item: $selectedTrip) { trip in
            EditTitleView(travel: trip)
        }

    }
    func editTitle(trip: Travel) {
        selectedTrip = trip
        isEditTitle.toggle()
    }
}
//
//#Preview {
//    MainView()
//}
