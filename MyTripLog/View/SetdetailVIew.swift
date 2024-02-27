//
//  SetdetailVIew.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI
import SwiftData

struct SetdetailVIew: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allTravels: [Travel]

//    @Binding var add : Bool
    @Binding var nameText : String
    @Binding var moveToATV : Bool
    @State private var selectedColor: Color = .purple
    @State private var addTagView: Bool = false
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
                Section("새로운 여정명"){
                    TextField("여정의 이름을 입력해주세요." , text: $nameText)
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
                        }
                        
                    }
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
                        )
                    .frame(width: 350, height: 150)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("여정 추가")
            .navigationBarTitleDisplayMode(.inline)
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
                    Button("취소") {
                        nameText = ""
                        startTime = 0
                        endTime = 0
                        moveToATV = false
                        dismiss()

                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
                        moveToATV = true
                        addTravel()

                        dismiss()

                    }
                    .disabled(nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allTravels.contains(where: { $0.title == nameText }))
                    .tint(.blue)
                }
            }
            
        }
        .onAppear{
            nameText = ""
            startDay = Date()
            endDay = startDay
            startTime = 0
            endTime = startTime + 1
            selectedImage = "USA"
        }
        .interactiveDismissDisabled()

    }
    func addTravel() {
        let travel = Travel(title: nameText, startDate: startDay, endDate: endDay, startTime: startTime, endTime: endTime, imageString: selectedImage ?? "USA")
        context.insert(travel)
       try? context.save()
        
    }
}

