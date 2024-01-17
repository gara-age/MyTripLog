//
//  Home.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI

struct Home: View {
    
    //View properties
    @State private var text : String = ""
    @State var tags: [Tag] = []
    @State private var title: String = "오사카 3박4일 여행"
    @State private var fontSize : CGFloat = 17
    @State private var day1Tags: [Tag] = []
    @State private var day2Tags: [Tag] = []
    @State private var day3Tags: [Tag] = []
    @State private var day4Tags: [Tag] = []
    @State  var ifDaysTagView : Bool = false
    
    var body: some View {
        NavigationStack{
                VStack{
                    ScrollView(.vertical){
                        TagView(tags: $tags)

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
                                ForEach(9..<24) { hour in
                                    VStack(spacing:10) {
                                        Text("\(String(format: "%02d", hour)):00")
                                        
                                        Divider()
                                            .frame(height: 0.1)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: 50)
                        
                        ScrollView(.horizontal,showsIndicators: false){
                                
                                HStack{
                                    Day1View()
//                                        .onDrop(of: ["public.text"], delegate: TagViewDragDropDelegate(tags: $tags, targetDay: $day1Tags))

                                        .frame(minWidth: 150)
                                    Day2View()
//                                        .onDrop(of: ["public.text"], delegate: TagViewDragDropDelegate(tags: $tags, targetDay: $day2Tags))

                                        .frame(minWidth: 150)
                                    Day3View()
//                                        .onDrop(of: ["public.text"], delegate: TagViewDragDropDelegate(tags: $tags, targetDay: $day3Tags))

                                        .frame(minWidth: 150)
                                    Day4View()
//                                        .onDrop(of: ["public.text"], delegate: TagViewDragDropDelegate(tags: $tags, targetDay: $day4Tags))

                                        .frame(minWidth: 150)
                                    
                                    Button{
                                        
                                    } label : {
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                        Spacer()
                                    }
                                    
                                }
                                .onTapGesture {
                                                                }
                                .background(.ultraThinMaterial)
                            
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
    
    
    //DayView의 height는 TimeView의 height만큼
    
    //Todo View
    @ViewBuilder
    func Day1View() -> some View{
        NavigationStack{
            Text("1일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day1Tags)

                    .frame(height: geometry.size.height)
            }
            
            
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        
    }
    //Working View
    @ViewBuilder
    func Day2View() -> some View{
        NavigationStack{
            Text("2일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day2Tags)

                    .frame(height: geometry.size.height)
            }
            
            
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        
    }
    //Completed View
    @ViewBuilder
    func Day3View() -> some View{
        NavigationStack{
            Text("3일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day3Tags)

                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
    //Completed View
    @ViewBuilder
    func Day4View() -> some View{
        NavigationStack{
            Text("4일차")
                .font(.system(size: fontSize))
            GeometryReader { geometry in
                
                DaysTagView(tags: $day4Tags)

                    .frame(height: geometry.size.height)
            }
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
}
//struct TagViewDragDropDelegate: DropDelegate {
//    @Binding var tags: [Tag]
//    @Binding var targetDay: [Tag]
//
//    func performDrop(info: DropInfo) -> Bool {
//        guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }
//
//        itemProvider.loadObject(ofClass: String.self) { (text, error) in
//            if let text = text as? String {
//                let droppedTag = addTag(text: text, fontSize: 16)
//                targetDay.append(droppedTag)
//                print("Drop By TagView")
//            }
//        }
//
//        return true
//    }
//
//    func validateDrop(info: DropInfo) -> Bool {
//        return info.hasItemsConforming(to: ["public.text"])
//    }
//}



#Preview {
    ContentView()
}
