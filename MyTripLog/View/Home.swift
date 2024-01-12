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
    
    var body: some View {
        NavigationStack{
                VStack{
                    ScrollView(.vertical){
                        TagView(tags: $tags)
                        
                    }
                    .background(.ultraThinMaterial)
                    .clipped()
                    
                    HStack{
                        TextField("apple", text: $text)
//                            .font(.title3)
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
                                Spacer(minLength: fontSize) //DayView의 text.height
                                ForEach(9..<24) { hour in
                                    VStack {
                                        Text("\(String(format: "%02d", hour)):00")
                                        
                                        Rectangle()
                                            .frame(height: 0.3)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(maxWidth: 50)
                        
                        ScrollView(.horizontal,showsIndicators: false){
                                
                                HStack{
                                    Day1View()
                                        .frame(minWidth: 150)
                                    Day2View()
                                        .frame(minWidth: 150)
                                    Day3View()
                                        .frame(minWidth: 150)
                                    Day4View()
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
            DaysTagView(tags: $day1Tags)
                .onDrop(of: ["public.text"], delegate: DragDropDelegate(tags: $tags, targetDay: $day1Tags))
            Spacer()
            
            
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
            DaysTagView(tags: $day2Tags)
                .onDrop(of: ["public.text"], delegate: DragDropDelegate(tags: $tags, targetDay: $day2Tags))
            Spacer()
            
            
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
            DaysTagView(tags: $day3Tags)
                .onDrop(of: ["public.text"], delegate: DragDropDelegate(tags: $tags, targetDay: $day3Tags))
            Spacer()
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
            DaysTagView(tags: $day4Tags)
                .onDrop(of: ["public.text"], delegate: DragDropDelegate(tags: $tags, targetDay: $day4Tags))
            Spacer()
        }
        .frame(maxWidth: 150)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
    }
}
struct DragDropDelegate: DropDelegate {
    @Binding var tags: [Tag]
    @Binding var targetDay: [Tag]

    func performDrop(info: DropInfo) -> Bool {
        // Getting the dropped item
        guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

        // Loading text from the dropped item
        itemProvider.loadObject(ofClass: String.self) { (text, error) in
            if let text = text as? String {
                // Creating a new tag from the dropped text
                let droppedTag = addTag(text: text, fontSize: 16)
                
                // Appending the new tag to the target day
                targetDay.append(droppedTag)
            }
        }

        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        // Allowing drops only if they contain text
        return info.hasItemsConforming(to: ["public.text"])
    }
}

#Preview {
    ContentView()
}
