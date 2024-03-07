//
//  EditDetailView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI
import SwiftData

struct EditDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allTravels: [Travel]
    @Query(animation: .snappy) private var allTags: [Tag]

    @Binding var selectedTravel : Travel
    @State private var newTitle : String = ""
    @State private var selectedColor: Color = .purple
    @State private var addTagView: Bool = false
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var calendarId: Int = 0

    var closedRange = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @State private var startTime : Int = 0
    @State private var endTime : Int = 0
    @State private var defaultTime : Int = 0
    @State private var showImage : Bool = false
    @State private var selectedImage: String = ""
    
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy.MM.dd"
           return formatter
       }()
    
    var body: some View {
        NavigationStack{
            List{
                Section("새로운 여정명"){
                    TextField(selectedTravel.title , text: $newTitle)
                }
                Section{
                    HStack{
                        VStack{
                            Section(header:(Text("전체 일정"))) {
                                DatePicker("일정 시작날짜", selection: $startDate, in: Date()..., displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))
                                    .id(calendarId)
                                    .onChange(of: startDate) { _ in
                                      calendarId += 1
                                    }

                            }
                            Section {
                                DatePicker("일정 종료날짜", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .environment(\.locale, Locale(identifier:"ko_KR"))
                                    .id(calendarId)
                                    .onChange(of: endDate) { _ in
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
                            Text(newTitle.isEmpty ? selectedTravel.title : newTitle)
                                .padding(.vertical)
                            Text("\(dateFormatter.string(from: startDate)) ~ \(dateFormatter.string(from:endDate))")

                            Spacer()
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.trailing, 80)
                    }
                    
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .overlay(Image(selectedImage.isEmpty ? selectedTravel.imageString : selectedImage)
                            .resizable()
                            .scaledToFill()
                            .colorMultiply(.gray))
                        .frame( width: 350, height: 150)
                        )
                    .frame(width: 350, height: 150)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("여정 수정")
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
                        newTitle = ""
                        startTime = 0
                        endTime = 0
                        dismiss()

                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
                        saveEditedTravel()

                        dismiss()

                    }
                    .disabled(allTravels.contains(where: { $0.title == newTitle }))
                    .tint(.blue)
                }
            }
            
        }
        .onAppear{
            newTitle = ""
            startDate = selectedTravel.startDate
            endDate = selectedTravel.endDate
            startTime = selectedTravel.startTime
            endTime = selectedTravel.endTime
        }
        .interactiveDismissDisabled()

    }
    func saveEditedTravel() {
        let oldTitle = selectedTravel.title
        
        if !newTitle.isEmpty {
            selectedTravel.title = newTitle
            let tagsToUpdate = allTags.filter { $0.travelTitle == oldTitle }
            for tag in tagsToUpdate {
                tag.travelTitle = newTitle
            }
        }
        selectedTravel.startDate = startDate
        selectedTravel.endDate = endDate
        selectedTravel.startTime = startTime
        selectedTravel.endTime = endTime
        
        if !selectedImage.isEmpty{
            selectedTravel.imageString = selectedImage
        }
        try? context.save()
        
    }
}

