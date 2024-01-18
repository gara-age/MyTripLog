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
                            Menu(content: {
                                Button {
                                    withAnimation {
                                        currentDayIndex -= 1
                                        if currentDayIndex == 8 {
                                            isPlusButtonVisible = true
                                        }
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
                        )
                }
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
    
    @ViewBuilder
    func Day1View() -> some View{
        NavigationStack{
            Text("1일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day1Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
            
            
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        
    }
    @ViewBuilder
    func Day2View() -> some View{
        NavigationStack{
            Text("2일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day2Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
            
            
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        
    }
    @ViewBuilder
    func Day3View() -> some View{
        NavigationStack{
            Text("3일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day3Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day4View() -> some View{
        NavigationStack{
            Text("4일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day4Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day5View() -> some View{
        NavigationStack{
            Text("5일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day5Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day6View() -> some View{
        NavigationStack{
            Text("6일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day6Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day7View() -> some View{
        NavigationStack{
            Text("7일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day7Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day8View() -> some View{
        NavigationStack{
            Text("8일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day8Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day9View() -> some View{
        NavigationStack{
            Text("9일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day9Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    @ViewBuilder
    func Day10View() -> some View{
        NavigationStack{
            Text("10일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day10Tags, tagView: $tagView)
                
                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
}



#Preview {
    ContentView()
}
