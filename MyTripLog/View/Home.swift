//
//  MainView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI
import SwiftData

struct Home: View {
    @Query(animation: .snappy) private var allTravels: [Travel]
    @Query(animation: .snappy) private var allTags: [Tag]

    @Environment(\.modelContext) private var context
    @State private var add : Bool = false
    @State private var searchText  = ""
    @State private var nameText : String = ""
    @State private var startTime : Int = 0
    @State private var endTime : Int = 0
    @State private var isEditTravel : Bool = false
    @State private var selectedTravel : Travel?
    @State private var travelWillEdit : Travel = Travel(title: "", startDate: Date(), endDate: Date(), startTime: 0, endTime: 0, imageString: "")
    @State private var deleteRequest = false
    @State private var moveToATV : Bool = false
    @State private var openATV = false
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(allTravels) { trip in
                    Section{
                        TravelCardView(trip: trip)
                            .onTapGesture {
                             openTravel(travel: trip)
                                     }
                            .contextMenu{
                                Button {
                                    editTravel(travel: trip)
                                    
                                } label: {
                                    Text("여정정보 수정")
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
                                    selectedTravel = trip
                                    deleteRequest.toggle()

                                    
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
                        if let selectedTravel = selectedTravel {
                            deleteTravel(selectedTravel)
                        }
                    }
                } label: {
                    Text("삭제")
                }
                
                Button(role: .cancel) {
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
            
            
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("검색"))
            
        }
        
        .overlay{
            if allTravels.isEmpty{
                ContentUnavailableView{
                    Label("생성된 여정이 없습니다" , systemImage: "suitcase.rolling")
                }
            }
        }
        .sheet(isPresented: $add, onDismiss: {
            if moveToATV {
                openATV.toggle()
            }
        }){
            SetdetailVIew(nameText: $nameText, moveToATV: $moveToATV, startTime: $startTime, endTime: $endTime)
        }

        .fullScreenCover(isPresented: $openATV) {
            AddTagView(startTime: $startTime,endTime: $endTime , nameText: $nameText, moveToATV: $moveToATV)
                  }

        .sheet(isPresented: $isEditTravel) {
            EditDetailView(selectedTravel: $travelWillEdit)
        }
        
    }
    func openTravel(travel: Travel) {
        nameText = travel.title
        startTime = travel.startTime
        endTime = travel.endTime
             openATV.toggle()
    }
    
    func editTravel(travel: Travel) {
        travelWillEdit = travel
        isEditTravel.toggle()
    }
    
    func deleteTravel(_ travel: Travel) {
        
          if let tags = travel.tag {
              for tag in tags {
                  if tag.travelTitle == travel.title {
                      context.delete(tag)
                  }
              }
          }
          context.delete(travel)
      }
}
