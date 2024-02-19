//
//  SetdetailVIew.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct SetdetailVIew: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var nameText : String
    @State private var selectedColor: Color = .purple
    @State private var add: Bool = false
    @State var currentTime = Date()
    var closedRange = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Binding var startTime : Int
    @Binding var endTime : Int
    @State private var defaultTime : Int = 0
    var body: some View {
        NavigationStack{
            List{
                Section("새로운 일정명"){
                    TextField("일정의 이름을 입력해주세요." , text: $nameText)
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("전체 일정"))) {
                                DatePicker("일정 시작날짜", selection: $currentTime, in: closedRange...Date(), displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))

                            }
                            Section {
                                DatePicker("일정 종료날짜", selection: $currentTime, in: closedRange...Date(), displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))
                            }
                        }
                    }
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("하루 일정"))) {
                                Picker("일정 시작 시간", selection: $startTime) {
                                             ForEach(0..<24) { hour in
                                                 Text("\(hour)").tag(hour)
                                             }
                                         }
                                .environment(\.locale, Locale(identifier:"ko_KR"))

                            }
                            Section {
                                Picker("일정 종료 시간", selection: $endTime) {
                                    ForEach(0..<24) { hour in
                                        if hour >= startTime {
                                            Text("\(hour)").tag(hour)
                                        }
                                    }
                                }
                                .environment(\.locale, Locale(identifier: "ko_KR"))
                            }

                            .onChange(of: startTime){
                                endTime = startTime + 1
                            }
                        }
                        
                    }
                }
                .onChange(of: startTime){
                    
                }
                Section{
                    ColorPicker("색상 선택", selection: $selectedColor)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("취소", comment:"")) {
                        dismiss()
                        nameText = ""
                        startTime = 0
                        endTime = 0
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("추가", comment:"")) {
                        add.toggle()
                    }
                    .disabled(nameText.isEmpty)
                    .tint(.blue)
                }
            }
            
        }
//        .presentationDetents([.height(340)])
        .interactiveDismissDisabled()
        .sheet(isPresented: $add, content: {
            Home(startTime: $startTime,endTime: $endTime , nameText: $nameText)
        })
    }
}

//#Preview {
//    SetdetailVIew()
//}
