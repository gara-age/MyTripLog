//
//  SetdetailVIew.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct SetdetailVIew: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Binding var nameText : String
    @State private var selectedColor: Color = .purple
    @State private var add: Bool = false
    @State var startDay = Date()
    @State var endDay = Date()
    @State private var calendarId: Int = 0

    var closedRange = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Binding var startTime : Int
    @Binding var endTime : Int
    @State private var defaultTime : Int = 0
    @State private var showImage : Bool = false
    @State private var selectedImage: String?
    
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy.MM.dd"
           return formatter
       }()
    
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
                                DatePicker("일정 시작날짜", selection: $startDay, in: Date()..., displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))
                                    .id(calendarId)
                                    .onChange(of: startDay) { _ in
                                      calendarId += 1
                                    }
                                //날짜 선택시 피커 닫히도록

                            }
                            Section {
                                DatePicker("일정 종료날짜", selection: $endDay, in: startDay..., displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))
                                    .id(calendarId)
                                    .onChange(of: endDay) { _ in
                                      calendarId += 1
                                    }
                            }
                        }
                    }
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("하루 일정"))) {
                                Picker("일정 시작 시간", selection: $startTime) {
                                             ForEach(0..<25) { hour in
                                                 Text("\(hour)").tag(hour)
                                             }
                                         }
                                .environment(\.locale, Locale(identifier:"ko_KR"))

                            }
                            Section {
                                Picker("일정 종료 시간", selection: $endTime) {
                                    ForEach(0..<25) { hour in
                                        if hour > startTime {
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
                HStack{
                        Section("이미지로 배경 설정"){
                            Spacer()
                            Image(systemName: "photo")
                                .contentShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture{
                                    showImage.toggle()
                                }
                        }
                }
                Section{
                    HStack{
                        VStack(alignment: .leading){
                            Text(nameText.isEmpty ? "일정의 이름을 입력해주세요." : nameText)
                                .padding(.vertical)
                            Text("\(dateFormatter.string(from: startDay)) ~ \(dateFormatter.string(from:endDay))")

                            Spacer()
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.trailing, 80)
                    }
                    
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                        .overlay(Image(selectedImage ?? "USA")
                            .resizable()
                            .scaledToFill()
                            .colorMultiply(.gray))
                        .frame( width: 350, height: 150)
                        /*.foregroundColor(Color.tag)*/)
                    .frame(width: 350, height: 150)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .disabled(showImage)

            .blur(radius: showImage ? 5 : 0)
            .overlay(
                ZStack{
                    if showImage {
                        ChoosePictureView(onClose: {
                                                showImage = false
                                            }, onSelectImage: { imageName in
                                                selectedImage = imageName // 선택한 이미지를 저장
                                                showImage = false

                                            })
                    }

                }
            )
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
                        addTravel()
                    }
                    .disabled(nameText.isEmpty)
                    .tint(.blue)
                }
            }
            
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $add, content: {
            Home(startTime: $startTime,endTime: $endTime , nameText: $nameText)
        })
    }
    func addTravel() {
        let travel = Travel(title: nameText, startDate: startDay, endDate: endDay, startTime: startTime, endTime: endTime, imageString: selectedImage ?? "USA")
        context.insert(travel)
       try? context.save()
    }
}

