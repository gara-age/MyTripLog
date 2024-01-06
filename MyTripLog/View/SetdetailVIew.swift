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

    var body: some View {
        NavigationStack{
            List{
                Section("새로운 일정명"){
                    TextField("일정의 이름을 입력해주세요." , text: $nameText) // 사용자가 일정을 드래그앤 드랍으로 놓은경우 선택한 일정의 이름이 나와야함
                }
                
                Section{
                    HStack{
                        VStack{
                            Section("일정 시작 시간"){
                                Text("오전 10시") //타임피거
                            }
                        }
                        VStack{
                            Section("일정 종료 시간"){
                                Text("오후 2시") //타임피거
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

                    }
                    .tint(.blue)
                }
            }

        }
        .presentationDetents([.height(340)])
        .interactiveDismissDisabled()
        
    }
}

#Preview {
    SetdetailVIew()
}
