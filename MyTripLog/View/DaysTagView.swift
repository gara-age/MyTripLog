//
//  DaysTagView.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI

// Custom View
struct DaysTagView: View {
    @Binding var tags: [Tag]
    @State private var draggedTag: Tag?
    @State private var dragOffset: CGSize = .zero
    var title: String = "Add Some Tags"
    var fontSize: CGFloat = 16
    @Binding var tagView: Bool
    @State private var combinedTags: [Tag]
    @Namespace var animation
    @State private var isEditing: Bool = false
     @State private var editedText: String = ""
    @Binding var tagText : String
    @Binding var setHeight : Bool
    @Binding var tagColor : Color
    @Binding var tagHeight : CGFloat
    @Binding var tagID : String
    @Binding var getTagColor : Color
    @Binding var startTime : Int
    @Binding var endTime : Int
    @State private var viewHeight : CGFloat = 0
    @Binding var tagSizeUpdatedNotificationReceived : Bool
    
    
    init(tags: Binding<[Tag]>, tagView: Binding<Bool>, setHeight: Binding<Bool>, tagText: Binding<String>, tagColor: Binding<Color>, tagHeight: Binding<CGFloat>, tagID: Binding<String>, getTagColor: Binding<Color>, startTime: Binding<Int>, endTime: Binding<Int>, tagSizeUpdatedNotificationReceived: Binding<Bool>) {
        self._tags = tags
        self._tagView = tagView
        self._setHeight = setHeight
        self._tagText = tagText
        self._tagColor = tagColor
        self._tagHeight = tagHeight
        self._tagID = tagID
        self._getTagColor = getTagColor
        self._startTime = startTime
        self._endTime = endTime
        self._tagSizeUpdatedNotificationReceived = tagSizeUpdatedNotificationReceived
        self._combinedTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "", color: .clear, height: 18), count: 48).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "", color: .clear, height: 18)
        } + tags.wrappedValue)
    }
//.onHover로 드랍 예상 위치 색 변하도록
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    let columns = Array(repeating: GridItem(spacing: 1), count: 1)

                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(combinedTags.indices, id: \.self) { index in
                            RowView(tag: combinedTags[index], index: index)
                                .if(combinedTags[index].text.isEmpty){ RowVIew in
                                    RowVIew.padding(.vertical,1.75)
                                }

                                .dropDestination(for: String.self) { items, location in
                                    draggedTag = nil
                                    return false
                                } isTargeted: { status in
                                    if let draggedTag, status, draggedTag != combinedTags[index] {
                                        if let sourceIndex = combinedTags.firstIndex(of: draggedTag),
                                           let destinationIndex = combinedTags.firstIndex(of: combinedTags[index]) {
                                                let sourceItem = combinedTags.remove(at: sourceIndex)
                                                combinedTags.insert(sourceItem, at: destinationIndex)
                                        }
                                    }
                                }
//                                .frame(height: fontSize + 20) //1시간으로 고정하려면 켜야함
                        }
                    }
                    .frame(width: 150, alignment: .center)
                }
   
                .scrollDisabled(true)
                .frame(maxWidth: .infinity)
                .onDrop(of: ["public.text"], delegate: tagView ? TagViewDragDropDelegate(tags: $combinedTags, combinedTags: $combinedTags, getTagColor: $getTagColor) : DaysTagViewDragDropDelegate(tags: $combinedTags))
            }
            .onAppear{
                let time = (startTime - endTime) * 36
                viewHeight = CGFloat(time)
            }
        }
   
    }
    //MARK: - RowView

    @ViewBuilder
    func RowView(tag: Tag, index: Int) -> some View {
        HStack {
            Text(tag.text)
                .font(.system(size: fontSize))
                .if(tag.text.isEmpty && !tagView){  draggableText in
                    draggableText.padding(.horizontal, 70)
                }
                .if(!tag.text.isEmpty){  draggableText in
                    draggableText
                        .frame(width: 150, height: tag.height)

                }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tag.text.isEmpty ? Color.clear :  tag.color)
                        .frame(width: 150)
                        .frame(height: tag.text.isEmpty ? 18 : tag.height)
                )
                .foregroundColor(Color("BG"))
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                              if !tag.text.isEmpty {
                                  Button("시간 변경") {
                                      tagID = tag.id
                                      tagHeight = tag.height
                                      tagColor = tag.color
                                      tagText = tag.text
                                      setHeight = true
                                      //if 태그들의 height == viewHeight {시간변경에서 +는 불가 처리 및 잔여시간 없음 안내, 일괄로 처리도 불가한 일정 외에 변경 됩니다 or 불가한 일정이 있어 처리가 어렵습니다}
                                      //일정이 꽉찬 DaysTagView에 tagText와 일치하는 Tag가 없을 경우 일괄 처리 가능
                                      
                                  }
                                  Button("삭제") {
                                      if let tagIndex = combinedTags.firstIndex(of: tag) {
                                          combinedTags.remove(at: tagIndex)
                                          //tagIndex의 tag
                                          combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18), at: tagIndex)
                                          combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18), at: tagIndex + 1)

                                      }
                                  }
                              }
//                    else { //일단 보류
//                        Button("일정 추가"){
//                            print("일정추가")
//                        }
//                    }
                          }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagSizeUpdated"))) { notification in
                    if let userInfo = notification.object as? [String: Any],
                       let tagText = userInfo["tagText"] as? String,
                       let tagHeight = userInfo["tagHeight"] as? Double,
                       let tagID = userInfo["tagID"] as? String ,
                       
                    let changeAll = userInfo["changeAll"] as? Bool{

                        if changeAll {
                                combinedTags.indices.forEach { index in

                                    if combinedTags[index].text == tagText {

                                        combinedTags[index].height = CGFloat(tagHeight * 36)
                                        print("changeAll")

                                    }
                                }

                        } else {
                                if let selectedTagIndex = combinedTags.firstIndex(where: { $0.text == tagText && $0.id == tagID }) {
                                    guard !tagSizeUpdatedNotificationReceived else { return }

                                    combinedTags[selectedTagIndex].height = CGFloat(tagHeight * 36)
                                    print("changeOne")

                                    tagSizeUpdatedNotificationReceived = true

                            }
                        }

                    }

                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagColorChanged"))) { notification in
                                    if let userInfo = notification.object as? [String: Any],
                                       let color = userInfo["color"] as? Color,
                                       let originalText = userInfo["originalText"] as? String {

                                        // Find and update all tags in combinedTags based on text
                                        combinedTags = combinedTags.map { existingTag in
                                            if existingTag.text == originalText {
                                                var updatedTag = existingTag
                                                updatedTag.color = color
                                                return updatedTag
                                            }
                                            else {
                                                return existingTag
                                            }
                                        }
                                    }
                                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagUpdated"))) { notification in
                                  if let userInfo = notification.object as? [String: Any],
                                     let updatedTag = userInfo["tag"] as? Tag,
                                     let newText = userInfo["newText"] as? String,
                                     let originalText = userInfo["originalText"] as? String {
                                      
                                      // Find and update the tag in combinedTags based on text
                                      if let index = combinedTags.firstIndex(where: { $0.text == originalText }) {
                                          // Update the tag in combinedTags
                                          combinedTags[index].text = newText
                                      }
                                  }
                              }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagDeleted"))) { notification in
                    if let deletedTag = notification.object as? Tag {
                        let copyDeletedTag = deletedTag
                        // Find tags in combinedTags with the same text as the deleted tag
                        let tagsWithSameText = combinedTags.filter { $0.text == copyDeletedTag.text }

                        // Use the height of each tag with the same text (if available)
                        for tagWithSameText in tagsWithSameText {
                            if let originalHeight = tagWithSameText.height as CGFloat? , originalHeight > 18 {
                                // Your existing code that uses originalHeight
                                let insertCount = Int(originalHeight / 18) - 1
                                if let tagIndex = combinedTags.firstIndex(where: { $0.text == tagWithSameText.text && $0.id == tagWithSameText.id }) {
                                    for _ in 0..<insertCount + 1 {
                                        combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18), at: tagIndex)
                                        print("tag inserted \(insertCount) times")
                                    }
                                }
                            }
                        }


                        removeTag(withText: deletedTag.text, from: &combinedTags)
                    }
                }

                .matchedGeometryEffect(id: tag.id, in: animation)
                .if(!tag.text.isEmpty) { draggableText in
                                draggableText.draggable(tag.text) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 1, height: 1)
                                        .onAppear {
                                            draggedTag = tag
                                            tagView = false
                                        }
                                }
                            }
        }

    }
    //MARK: - Function
    

    //MARK: - DragDropDelegate

    struct DaysTagViewDragDropDelegate: DropDelegate {
        @Binding var tags: [Tag]

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

            return false
        }

        func validateDrop(info: DropInfo) -> Bool {
            return info.hasItemsConforming(to: ["public.text"])
        }
    }

    struct TagViewDragDropDelegate: DropDelegate {
        @Binding var tags: [Tag]
        @Binding var combinedTags: [Tag]
        @Binding var getTagColor: Color

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

            itemProvider.loadObject(ofClass: String.self) { (text, error) in
                if let text = text as? String {
                    var droppedTag = MyTripLog.addTag(text: text, fontSize: 16)

                    let location = info.location

                    let index = Int(floor(location.y / (18)))

                    if index >= 0 && index < combinedTags.count {
                        combinedTags.remove(at: index)

                        // Check if the tag at index + 1 is empty and remove it
                        if index + 1 < combinedTags.count, combinedTags[index + 1].text.isEmpty {
                            combinedTags.remove(at: index + 1)
                        }

                        let color = Color(hue: Double(text.hashValue % 100) / 100.0, saturation: 0.8, brightness: 0.8)

                        let originalColor = tags.first { $0.text == text }?.color ?? getTagColor
                        droppedTag.color = originalColor

                        tags.insert(droppedTag, at: index)
                    }
                }
            }

            return true
        }

        func validateDrop(info: DropInfo) -> Bool {
            return info.hasItemsConforming(to: ["public.text"])
        }
    }

}
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}



#Preview {
    ContentView()
}
