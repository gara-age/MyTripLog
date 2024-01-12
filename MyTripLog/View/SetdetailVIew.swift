//
//  SetdetailVIew.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct SetdetailVIew: View {
    @Environment(\.dismiss) private var dismiss

    @State private var nameText : String = ""
    @State private var selectedColor: Color = .purple
    @State private var add: Bool = false
    @State var currentTime = Date()
    var closedRange = Calendar.current.date(byAdding: .year, value: -1, to: Date())!

    var body: some View {
        NavigationStack{
            List{
                Section("새로운 일정명"){
                    TextField("일정의 이름을 입력해주세요." , text: $nameText) // 사용자가 일정을 드래그앤 드랍으로 놓은경우 선택한 일정의 이름이 나와야함
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("일정 시작날짜"))) {
                                DatePicker("Pick a past date:", selection: $currentTime, in: closedRange...Date(), displayedComponents: .date) // Only pick a past date
                            }
                            Section(header:(Text("일정 종료날짜"))) {
                                DatePicker("Pick a past date:", selection: $currentTime, in: closedRange...Date(), displayedComponents: .date) // Only pick a past date
                            }
                        }
                    }
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("하루일정의 시작시간"))) {
                                DatePicker("Pick a time:", selection: $currentTime, displayedComponents: .hourAndMinute)
                            }
                            Section(header:(Text("하루일정의 종료시간"))) {
                                DatePicker("Pick a time:", selection: $currentTime, displayedComponents: .hourAndMinute)
                            }
                        }

                    }
                }
                Section{
                    ColorPicker("색상 선택", selection: $selectedColor)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("취소", comment:"")) {
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("추가", comment:"")) {
                        add.toggle()
                    }
                    .tint(.blue)
                }
            }

        }
        .presentationDetents([.height(340)])
        .interactiveDismissDisabled()
        .sheet(isPresented: $add, content: {
            Home()
        })
    }
}

#Preview {
    SetdetailVIew()
}
