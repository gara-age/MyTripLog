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
    @State var combinedTags: [Tag] = []
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
    @State private var editMode: Bool = false
    @State private var editedTag: Tag?
    @State private var editedText: String = ""
    @State private var originalText: String = ""
    @State private var originalColor : Color = .red
    @State private var colorEditMode: Bool = false
    @State private var setHeight : Bool = false
    @State private var tagText : String = ""
    @State private var tagColor : Color = .clear
    @State private var selectedTagTime: Double = 1.0
    @State private var tagTime : CGFloat = 1.0
    @State private var tagHeight : CGFloat = 36
    @State private var tagID: String = ""
    @State private var changeAll : Bool = false
    @State private var getTagColor : Color = .clear

    var body: some View {
        NavigationStack{
            VStack{
                //MARK: -TagView
                
                ScrollView(.vertical){
                    TagView(tags: $tags, tagView: $tagView, editMode: $editMode, originalText: $originalText, getTagColor: $getTagColor, updateTags: updateTags)
                }
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity)
                .clipped()
                
                HStack{
                    TextField("apple", text: $text) // 동일한 Tag생성 막을지 말지
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("Tag").opacity(0.2), lineWidth: 1))
                    Button {
                        // Adding Tag
                        let newTag = addTag(text: text, fontSize: 16)
                        
                        // Check if a tag with the same text already exists and if the text is not just whitespace
                        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                           !tags.contains(where: { $0.text == newTag.text }) {
                            tags.append(newTag)
                            text = ""
                        }
                    } label: {
                        Text("Add")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("BG"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 45)
                            .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tags.contains(where: { $0.text == text }) ? Color.gray : Color("Tag"))
                            .cornerRadius(10)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tags.contains(where: { $0.text == text }))


                }
            }
            .background(.ultraThinMaterial)
            .blur(radius: editMode || setHeight ? 5 : 0)

            ScrollView(.vertical,showsIndicators: false){
                HStack{
                    VStack {
                        Spacer(minLength: fontSize + 21)
                        ForEach(9..<24) { hour in
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
                            //MARK: - Time and DayView
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
            .blur(radius: editMode || setHeight ? 5 : 0)

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
        .disabled(editMode || setHeight)
        .overlay(
                    ColorPicker("", selection: $originalColor, supportsOpacity: false)
                        .labelsHidden()
                        .opacity(0)
                        .onChange(of: originalColor) { newColor in
                            // Post a notification with the selected color and originalText
                            NotificationCenter.default.post(
                                name: Notification.Name("TagColorChanged"),
                                object: ["color": newColor, "originalText": originalText]
                            )

                        }
                )
        .overlay{
            ZStack{
                if editMode {
                    EditRowTextView(editedText: $editedText, tags: $tags, originalText: $originalText, onSubmit: {
                        // Update the tags in TagView
                        if let editedTag = editedTag, let index = tags.firstIndex(of: editedTag) {
                            tags[index].text = editedText
                        }
                       
                        NotificationCenter.default.post(name: Notification.Name("TagUpdated"), object: ["tag": editedTag, "newText": editedText, "originalText": originalText])
                        // Update the tags in DaysTagView
                        // (You may need to pass similar update logic to DaysTagView)
                        
                        // Reset the editedTag and editedText
                        editedTag = nil
                        editedText = ""
                        
                        // Close the EditRowTextView
                        editMode = false
                    }, onClose: {
                        // Close the EditRowTextView
                        editMode = false
                    })
                    .transition(.opacity)
                }
            }
            .animation(.snappy, value: editMode)
        }
        .overlay{
            ZStack{
                if setHeight {
                    TagReSizingVIew(tagText: $tagText,tagColor: $tagColor, tagTime: $tagTime,tagHeight: $tagHeight,tagID: $tagID,changeAll: $changeAll, onSubmit: {
                        updateSelectedTagTime(tagTime: tagTime)

                    }, onClose: {
                        setHeight = false
                    })
                
                    .transition(.opacity)
                }
            }
            .animation(.snappy, value: setHeight)
        }

    }
    func updateSelectedTagTime(tagTime: Double) {
           selectedTagTime = tagTime
        NotificationCenter.default.post(name: Notification.Name("TagSizeUpdated"), object: ["tagText": tagText, "tagHeight": selectedTagTime, "tagID": tagID, "changeAll": changeAll])
        setHeight = false
        tagText = ""
        tagID = ""
        changeAll = false
       }

       
    
    func updateTags(tag: Tag, newText: String) {
        // Update the editedTag and editedText
        editedTag = tag
        editedText = newText
        
        // Show the EditRowTextView
        editMode = true
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
    //MARK: - getDayView
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
                DaysTagView(tags: getTagBinding(for: index), tagView: $tagView, setHeight: $setHeight, tagText: $tagText, tagColor: $tagColor, tagHeight: $tagHeight, tagID: $tagID, getTagColor: $getTagColor)
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

extension UIColorWell {

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let uiButton = self.subviews.first?.subviews.last as? UIButton {
            UIColorWellHelper.helper.execute = {
                uiButton.sendActions(for: .touchUpInside)
            }
        }
    }
}

class UIColorWellHelper: NSObject {
    static let helper = UIColorWellHelper()
    var execute: (() -> ())?
    @objc func handler(_ sender: Any) {
        execute?()
    }
}


#Preview {
    ContentView()
}
