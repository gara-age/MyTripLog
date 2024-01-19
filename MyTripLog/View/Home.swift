//
//  Home.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI

struct Home: View {
    @Environment(\.dismiss) private var dismiss
    
    //View properties
    @State private var text : String = ""
    @State var tags: [Tag] = []
    @State private var title: String = "오사카 3박4일 여행"
    @State private var fontSize : CGFloat = 17
    @State private var day1Tags: [Tag] = []
    @State private var day2Tags: [Tag] = []
    @State private var day3Tags: [Tag] = []
    @State private var day4Tags: [Tag] = []
    @State private var day5Tags: [Tag] = []
    @State private var day6Tags: [Tag] = []
    @State private var day7Tags: [Tag] = []
    @State private var day8Tags: [Tag] = []
    @State private var day9Tags: [Tag] = []
    @State private var day10Tags: [Tag] = []
    @State private var currentDayIndex = 0
    @State private var isPlusButtonVisible = true
    @State  var ifDaysTagView : Bool = false
    @State private var tagView : Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical){
                    TagView(tags: $tags, tagView: $tagView)
                    
                }
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity)
                .clipped()
                
                HStack{
                    TextField("apple", text: $text)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("Tag").opacity(0.2), lineWidth: 1))
                    Button{
                        // Adding Tag
                        tags.append(addTag(text: text, fontSize: 16))
                        text = ""
                    } label: {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("BG"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 45)
                            .background(Color("Tag"))
                            .cornerRadius(10)
                    }
                    .disabled(text.isEmpty)
                }
                //                    .background(.ultraThinMaterial)
            }
            .background(.ultraThinMaterial)
            
            ScrollView(.vertical,showsIndicators: false){
                HStack{
                    VStack {
                        Spacer(minLength: fontSize + 21) //DayView의 text.height
                        ForEach(9..<21) { hour in
                            VStack(spacing:10) {
                                Text("\(String(format: "%02d", hour)):00")
                                
                                Divider()
                                    .frame(height: 0.1)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    .frame(maxWidth: 50)
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        
                        HStack{
                            ForEach(0..<(currentDayIndex + 1), id: \.self) { dayIndex in
                                getDayView(for: dayIndex)
                                    .frame(minWidth: 150)
                                
                            }
                            
                            if isPlusButtonVisible {
                                Button {
                                    withAnimation {
                                        currentDayIndex += 1
                                        if currentDayIndex == 9 {
                                            isPlusButtonVisible = false
                                        }
                                    }
                                } label: {
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Spacer()
                                }
                            }
                            
                        }
                        
                        .background(.clear)
                        
                    }
                    
                }
                
            }
            
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
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
        
    }
    
    private func getTagBinding(for index: Int) -> Binding<[Tag]> {
        switch index {
        case 0:
            return $day1Tags
        case 1:
            return $day2Tags
        case 2:
            return $day3Tags
        case 3:
            return $day4Tags
        case 4:
            return $day5Tags
        case 5:
            return $day6Tags
        case 6:
            return $day7Tags
        case 7:
            return $day8Tags
        case 8:
            return $day9Tags
        case 9:
            return $day10Tags
        default:
            return $day1Tags
        }
    }
    func getDayView(for index: Int) -> some View {
        NavigationStack {
            VStack{
                if index == 0 {
                    Text("\(index + 1)일차")
                        .font(.system(size: fontSize))
                } else {
                    HStack {
                        Spacer()
                        Text("\(index + 1)일차")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .overlay(
                                Group {
                                    if index == currentDayIndex {
                                        Menu(content: {
                                            Button {
                                                withAnimation {
                                                    deleteDay(at: index)
                                                }
                                            } label: {
                                                Text("지우기")
                                            }
                                        }, label: {
                                            Image(systemName: "ellipsis")
                                                .rotationEffect(.degrees(90))
                                                .frame(width: 30, height: 30)
                                        })
                                        .contentShape(Rectangle().size(width: 100, height: 100))
                                        .padding(.horizontal, 5)
                                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                                    }
                                }
                            )                }
                    .font(.system(size: fontSize))
                }
            }
            .padding(.top, 10)
            GeometryReader { geometry in
                DaysTagView(tags: getTagBinding(for: index), tagView: $tagView)
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    
    private func deleteDay(at index: Int) {
        switch index {
        case 1:
            day2Tags.removeAll()
        case 2:
            day3Tags.removeAll()
        case 3:
            day4Tags.removeAll()
        case 4:
            day5Tags.removeAll()
        case 5:
            day6Tags.removeAll()
        case 6:
            day7Tags.removeAll()
        case 7:
            day8Tags.removeAll()
        case 8:
            day9Tags.removeAll()
        case 9:
            day10Tags.removeAll()
        default:
            break
        }
        currentDayIndex -= 1
        if currentDayIndex == 8 {
            isPlusButtonVisible = true
        }
    }
}



#Preview {
    ContentView()
}
