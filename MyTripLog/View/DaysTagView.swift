//　수정본
//  DaysTagView.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI
import Foundation

// Custom View
struct DaysTagView: View {
    @Binding var tags: [Tag]
    @Binding var draggedTag: Tag?
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
    @Binding var tagTime : CGFloat
    @State private var originalTag : Tag?
    @Binding var dropDone : Bool
    @State private var emptyTags: [Tag]
    @State private var lastIndex = 0
    @Binding var escape : Bool
    let startFunction: () -> Void
    let cancelFunction: () -> Void
    let taskManager = TaskManager()
    @State private var secTimer: Timer?
    @State private var timeSpentInView: TimeInterval = 0
    let threshold: TimeInterval = 1.5
    @Binding var dayIndex : Int
    @State private var totalHeight: CGFloat = 0
    @State private var copyedCombinedTags: [Tag]
    @Binding var forReset : Bool
    
    init(tags: Binding<[Tag]>, tagView: Binding<Bool>, setHeight: Binding<Bool>, tagText: Binding<String>, tagColor: Binding<Color>, tagHeight: Binding<CGFloat>, tagID: Binding<String>, getTagColor: Binding<Color>, startTime: Binding<Int>, endTime: Binding<Int>, tagTime: Binding<CGFloat>,draggedTag: Binding<Tag?>, dropDone: Binding<Bool>, escape: Binding<Bool>, startFunction: @escaping () -> Void, cancelFunction: @escaping () -> Void, dayIndex: Binding<Int>, forReset: Binding<Bool>) {
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
        self._tagTime = tagTime
        self._draggedTag = draggedTag
        self._dropDone = dropDone
        self._escape = escape
        self.startFunction = startFunction
        self.cancelFunction = cancelFunction
        self._dayIndex = dayIndex
        self._forReset = forReset
        let repeatCount = (startTime.wrappedValue - endTime.wrappedValue) * 2
            let tagRepeatCount: Int
           if repeatCount < 0 {
               tagRepeatCount = -repeatCount
           } else {
               tagRepeatCount = repeatCount
           }

        self._emptyTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "12345", color: .clear, height: 18, fontColor: .clear), count: 100).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "12345", color: .clear, height: 18, fontColor: .clear)
        })
        self._combinedTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear), count: tagRepeatCount).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "" , color: .clear, height: 18, fontColor: .clear)
        } + tags.wrappedValue)
        self._copyedCombinedTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear), count: tagRepeatCount).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "" , color: .clear, height: 18, fontColor: .clear)
        } + tags.wrappedValue)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    //PadOs에도 맞게 스페이싱 조절해야함
                    let columns = Array(repeating: GridItem(spacing: 1), count: 1)
                    
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(combinedTags.indices, id: \.self) { index in

                            RowView(tag: combinedTags[index], index: index)
                                .if(combinedTags[index].text.isEmpty){ RowVIew in
                                    RowVIew.padding(.vertical,1.725)
                                }

                                .if(!tagView){ RowView in
                                    RowView
                                      
                                        .dropDestination(for: String.self) { items, location in
                                            draggedTag = nil
                                            return false
                                        } isTargeted: { status in
                                            if let draggedTag, status, draggedTag != combinedTags[index] {
                                                dropDone = false
                                                if let sourceIndex = combinedTags.firstIndex(of: draggedTag),
                                                   let destinationIndex = combinedTags.firstIndex(of: combinedTags[index]) {
                                                    let sourceItem = combinedTags.remove(at: sourceIndex)
                                                    combinedTags.insert(sourceItem, at: destinationIndex)
                                                    
                                                }
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
                .onDrop(of: ["public.text"], delegate: tagView ? dropDone ? TagViewDragDropDelegate(tags: $combinedTags, combinedTags: $combinedTags, getTagColor: $getTagColor, tagView: $tagView, draggedTag: $draggedTag) : TagViewDragDropDelegate(tags: $combinedTags, combinedTags: $combinedTags, getTagColor: $getTagColor, tagView: $tagView, draggedTag: $draggedTag) : DaysTagViewDragDropDelegate(tags: $combinedTags))
            }
            .onChange(of: totalHeight){
                print("모든 Tag의 높이의 합:", totalHeight)

            }
            .onAppear{
                for tag in combinedTags {
                    totalHeight += tag.height
                }
            }
            .overlay{
                //MARK: - Overlay
                
                ZStack {
                    if tagView && !dropDone {
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            let columns = Array(repeating: GridItem(spacing: 1), count: 1)

                            LazyVGrid(columns: columns, spacing: 0.44) {
                                ForEach(copyedCombinedTags.indices, id: \.self) { index in
                                    CopyRowView(tag: copyedCombinedTags[index], index: index)
                                        .if(!copyedCombinedTags[index].text.isEmpty) {
                                            $0
                                                .padding(.vertical, 0 )
                                        }
                                        .if(tagView && !dropDone){ RowView in
                                            RowView
                                                .dropDestination(for: String.self) { items, location in
                                                    cancelFunction()
                                                    if dayIndex >= 1 {
                                                        stopSingleTimer()
                                                    }
                                                    var droppedTag = MyTripLog.addTag(text: draggedTag!.text, fontSize: 16)
                                                    //드랍 조건 확인해볼것. 대형 Tag의 아래쪽에 드랍 무시되거나 멀리 떨어져서 드랍되는 경우 발생
                                                    if lastIndex >= 0 && lastIndex < combinedTags.count , combinedTags[index].text.isEmpty {
                                                        //Tag 덮어씌우지 못하도록 처리
                                                        combinedTags.remove(at: index)
                                                            combinedTags.append(Tag(text: "", color: .clear, height: 18, fontColor: .clear))
                                                        // Check if the tag at index + 1 is empty and remove it
                                                        if lastIndex + 1 < combinedTags.count, combinedTags[lastIndex + 1].text.isEmpty {
                                                            combinedTags.remove(at: lastIndex + 1)
                                                        }
                                                        
                                                        let color = Color(hue: Double(draggedTag!.text.hashValue % 100) / 100.0, saturation: 0.8, brightness: 0.8)
                                                        
                                                        let originalColor = tags.first { $0.text == draggedTag!.text }?.color ?? getTagColor
                                                        droppedTag.color = originalColor
                                                        
                                                        combinedTags.insert(droppedTag, at: lastIndex)

                                                    }
                                                    

                                                    draggedTag = nil
                                                    dropDone = true
                                                    tagView = false
                                                    escape = false
                                                    
                                                    return false
                                                } isTargeted: { status in
//                                                    forReset.toggle()

                                                    let draggedTag = self.draggedTag
                                                    if let draggedTag, status, draggedTag != copyedCombinedTags[index] {

                                                        cancelFunction()
                                                        stopSingleTimer()
                                                        
                                                        if index == 0 {
                                                            copyedCombinedTags[0] = draggedTag
                                                        }
                                                        if copyedCombinedTags[0].text == "12345" {
                                                            copyedCombinedTags[0] = draggedTag
                                                        }
                                                        if let sourceIndex = copyedCombinedTags.firstIndex(of: draggedTag),
                                                           let destinationIndex = copyedCombinedTags.firstIndex(of: copyedCombinedTags[index]) {

                                                            let sourceItem = copyedCombinedTags.remove(at: sourceIndex)
                                                            for index in (0..<copyedCombinedTags.count) {

                                                                copyedCombinedTags[index] = Tag(text: "12345", color: .clear, height: combinedTags[index].height, fontColor: .clear)

                                                              
                                                            }
                                                            if destinationIndex > 0 && combinedTags[destinationIndex + 1].height >= 36 {
                                                                    copyedCombinedTags.insert(sourceItem, at: destinationIndex + 1)
                                                                print("aaa")
                                                            }
                                                            else if destinationIndex > 0 {
                                                                copyedCombinedTags.insert(sourceItem, at: destinationIndex)
                                                                print("bbb")
                                                            }
                                                           else {
                                                                copyedCombinedTags.insert(sourceItem, at: destinationIndex)
                                                                print("dddd")
                                                            }
                                                            print("index is \(destinationIndex)")
                                                            lastIndex = destinationIndex
                                                            startFunction()
                                                            if dayIndex > 0 {
                                                                startSingleTimer()
                                                            }
                                                        }

                                                    }

                                                }
                                            
                                        }
                                }
                            }
                            .frame(width: 150, alignment: .center)
                        }
                        .onAppear{
                            copyedCombinedTags = combinedTags
                            for index in (0..<copyedCombinedTags.count) {
                                if !copyedCombinedTags[index].text.isEmpty{
//                                    continue
                                    copyedCombinedTags[index] = Tag(text: copyedCombinedTags[index].text, color: copyedCombinedTags[index].color, height: copyedCombinedTags[index].height, fontColor: copyedCombinedTags[index].fontColor)

                                }
                                copyedCombinedTags[index] = Tag(text: "12345", color: .clear, height: 18, fontColor: .clear)
                            }
                           
                        }
                        .scrollDisabled(true)
                        
                    }
                }
                .onChange(of: escape) {
                    if escape {
                        emptyTags[lastIndex] = Tag(text: "12345", color: .clear, height: 18, fontColor: .clear)
                        
                    }
                }
                .onChange(of: tagView) {
                    if !tagView {
                        stopSingleTimer()
                    }
                }
             
            } //overlay 끝
        }
        
    }
    //MARK: - RowView
    
    @ViewBuilder
    func RowView(tag: Tag, index: Int) -> some View {
        HStack { //tagView 인 경우 combinedTags[0]의 tag.text 를 draggedTag.text로
            var draggedTag = draggedTag
            var paddingCount = ((combinedTags[index].height / 18) - 0) / 2.3

            Text(tag.text.isEmpty ? "" : tag.text)
                .font(.system(size: fontSize))
                .if(tag.text.isEmpty && !tagView){  draggableText in
                    draggableText.padding(.horizontal, 70)
                }
                .if(!tag.text.isEmpty && tag.height > 36){  draggableText in
                    draggableText
                        .frame(width: 150, height: tag.height + paddingCount)
                }
                .if(!tag.text.isEmpty && tag.height <= 36){  draggableText in
                    draggableText
                        .frame(width: 150, height: tag.height)
                }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tag.text.isEmpty ? Color.clear :  tag.color)
                        .frame(width: 150)
                        .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                )
                .foregroundColor(tag.fontColor)
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                    if !tag.text.isEmpty {
                        Button("시간 변경") {
                            DispatchQueue.main.async {
                                tagID = tag.id
                                tagHeight = tag.height
                                tagTime = tagHeight / 36
                                
                                tagColor = tag.color
                                tagText = tag.text
                                setHeight = true
                            }

                            //if 태그들의 height == viewHeight {시간변경에서 +는 불가 처리 및 잔여시간 없음 안내, 일괄로 처리도 불가한 일정 외에 변경 됩니다 or 불가한 일정이 있어 처리가 어렵습니다}
                            //일정이 꽉찬 DaysTagView에 tagText와 일치하는 Tag가 없을 경우 일괄 처리 가능
                                
                        }
                        Button("삭제") {
                            //삭제전 태그의 height / 18 -1 만큼 투명 태그 인서트 해야함
                            if let tagIndex = combinedTags.firstIndex(of: tag) {
                                let insertCount = Int(tag.height / 18)

                                combinedTags.remove(at: tagIndex)
                                //tagIndex의 tag
                                for _ in 0..<insertCount {
                                    combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear), at: tagIndex)
                                }
                                
                            }
                        }
                    }
                    
                }

                .if(!tag.text.isEmpty && tag.text == tagText){ RowView in
                    RowView
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagSizeUpdated"))) { notification in
                            if let userInfo = notification.object as? [String: Any],
                               let tagText = userInfo["tagText"] as? String,
                               let tagHeight = userInfo["tagHeight"] as? Double,
                               let tagID = userInfo["tagID"] as? String ,
                               let changeAll = userInfo["changeAll"] as? Bool {
                                
                                if changeAll {
                                    combinedTags.indices.forEach { index in
                                        for index in (0..<combinedTags.count).reversed() {
                                            let tag = combinedTags[index]
                                            // 여기서 tag를 사용하여 작업을 수행합니다.
                                            // 작업이 완료된 후에 combinedTags 배열을 변경할 수 있습니다.
                                            if combinedTags[index].text == tagText {
                                                //변경 완료 후 사이즈가 변경되지않은 Tag가 있다면 다시 한번 처리하도록 해야함
                                                let originalHeight = combinedTags[index].height
                                                //                                            combinedTags[index].height = CGFloat(tagHeight * 36)
                                                updateTagHeight(selectedTagIndex: index, originalHeight: originalHeight, tagHeight: tagHeight)
                                                
                                                
                                                print("changeAll")
                                            }
                                            
                                        }
                                    }
                                } else {
                                    if let selectedTagIndex = combinedTags.firstIndex(where: { $0.text == tagText && $0.id == tagID }) {
                                        let originalHeight = combinedTags[selectedTagIndex].height
                                        
                                        updateTagHeight(selectedTagIndex: selectedTagIndex, originalHeight: originalHeight, tagHeight: tagHeight)
                                        
                                        print("changeOne")
                                        
                                        
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
                                                combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear), at: tagIndex)
                                                print("tag inserted \(insertCount) times")
                                            }
                                        }
                                    }
                                    //각 Tag별 height에 맞게 보완 필요
                                }
                                
                                
                                removeTag(withText: deletedTag.text, from: &combinedTags)
                            }
                        }
                }
            
            
        }
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
    
    @ViewBuilder
    func CopyRowView(tag: Tag, index: Int) -> some View {
        if index == 0 {
            HStack { //tagView 인 경우 combinedTags[0]의 tag.text 를 draggedTag.text로
                var draggedTag = draggedTag
                var paddingCount = ((copyedCombinedTags[index].height / 18) - 0) / 2.3
                Text(index == 0 ? draggedTag!.text.isEmpty ? "12345" : draggedTag!.text : tag.text.isEmpty ? "12345" : tag.text)
                    .font(.system(size: fontSize))
                    .if(tag.text.isEmpty && !tagView){  draggableText in
                        draggableText.padding(.horizontal, 70)
                    }
                    .if(!tag.text.isEmpty && tag.height > 36){  draggableText in
                        draggableText
                            .frame(width: 150, height: tag.height + paddingCount)
                    }
                    .if(!tag.text.isEmpty && tag.height <= 36){  draggableText in
                        draggableText
                            .frame(width: 150, height: tag.height)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(tag.text.isEmpty || tag.text == "12345" ? tag.height > 18 ? Color.clear : Color.clear :  tag.color)
                            .frame(width: 150)
                            .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                    )
                    .foregroundColor(.clear)
                    .lineLimit(nil)
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
          
        } else {
            HStack {
                var draggedTag = draggedTag
                var paddingCount = ((copyedCombinedTags[index].height / 18) - 0) / 2.3
                
                Text("12345")
                    .font(.system(size: fontSize))
                    .if(tag.text.isEmpty && !tagView){  draggableText in
                        draggableText.padding(.horizontal, 70)
                    }
                    .if(!tag.text.isEmpty && tag.height > 36){  draggableText in
                        draggableText
                            .frame(width: 150, height: tag.height + paddingCount)
                    }
                    .if(!tag.text.isEmpty && tag.height <= 36){  draggableText in
                        draggableText
                            .frame(width: 150, height: tag.height)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(tag.text.isEmpty || tag.text == "12345" ? tag.height > 18 ? Color.clear : Color.clear :  tag.color)
                            .frame(width: 150)
                            .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                    )
                    .foregroundColor(.clear)
                    .lineLimit(nil)
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }

        }

    }
    @ViewBuilder
    func emptyRowView(tag: Tag, index: Int) -> some View {
        HStack {
            let draggedTag = draggedTag
            
            Text(index == 0 ? draggedTag!.text.isEmpty ? "" : draggedTag!.text : tag.text.isEmpty ? "12345" : tag.text)
                .font(.system(size: fontSize))
                .if(!tag.text.isEmpty || tag.text == "12345"){  draggableText in
                    draggableText
                        .frame(width: 150, height: tag.height)
                }
            
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tag.text.isEmpty || tag.text == "12345" ? Color.clear :  tag.color)
                        .frame(width: 150)
                        .frame(height: tag.text == "12345" ? 18 : tag.height)
                )
                .foregroundColor(tag.fontColor)
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
            
            
        }
    }
    //MARK: - Function
    
    func updateTagHeight(selectedTagIndex: Int, originalHeight: CGFloat, tagHeight: Double) {
        
        // combinedTags[selectedTagIndex + 1]이 비어 있는지 확인하고 필요에 따라 조정
        //만약 selectedTagIndex +insertCount or removalCount의 위치에 공백 Tag가 아닌 Tag가 있다면 insert나 remove를 멈춰야함
        
        let originalHeight = combinedTags[selectedTagIndex].height
        
        let tagOriginalHeight = originalHeight
        // combinedTags[selectedTagIndex + insertCount or RemovalCount] 만큼의 텍스트가 비어있는지 확인
        // 비어있지않을 경우 비어있는 Tag의 갯수 만큼만 insert or remove
        if combinedTags[selectedTagIndex + 1].text.isEmpty{
            if tagHeight > 1 {
                //목표시간이 1시간 반 이상이고
                if originalHeight == 36 {
                    //현재 시간이 1시간일때
                    var removalCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                        if removalCount < 0 {
                            removalCount = removalCount * -1
                            for i in 1...removalCount {
                                let nextIndex = selectedTagIndex + i
                                if nextIndex < combinedTags.count {
                                    // 만약 다음 인덱스의 태그가 비어 있지 않으면 반복을 멈춥니다.
                                    if !combinedTags[nextIndex].text.isEmpty {
                                        break
                                    }
                                    combinedTags.remove(at: nextIndex)
                                }
                            }

                            
                        }
                }
                else if originalHeight > 36 {
                    //현재시간이 1시간 반 이상일때
                    var removalCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                    if removalCount < 0 {
                        removalCount = removalCount * -1
                            for i in 1...removalCount {
                                let nextIndex = selectedTagIndex + i
                                if nextIndex < combinedTags.count {
                                    // 만약 다음 인덱스의 태그가 비어 있지 않으면 반복을 멈춥니다.
                                    if !combinedTags[nextIndex].text.isEmpty {
                                        break
                                    }
                                    combinedTags.remove(at: nextIndex)
                                }
                            }
                    } else {
                            //2시간 이상에서 현재시간을 1시간 반 으로 줄일때
                            let insertCount = removalCount
                            if insertCount != 0 {
                                for i in 1...insertCount {
                                    if selectedTagIndex + i < combinedTags.count {
                                        combinedTags.insert(Tag(text: "", color: .clear, height: 18, fontColor: .clear), at: selectedTagIndex + 1)
                                    }
                                }
                            }
                    }
                } else if originalHeight < 36 {
                        //현재시간이 30분 일때
                        var removalCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                        if removalCount < 0 {
                            removalCount = removalCount * -1
                            for i in 1...removalCount {
                                let nextIndex = selectedTagIndex + i
                                if nextIndex < combinedTags.count {
                                    // 만약 다음 인덱스의 태그가 비어 있지 않으면 반복을 멈춥니다.
                                    if !combinedTags[nextIndex].text.isEmpty {
                                        break
                                    }
                                    combinedTags.remove(at: nextIndex)
                                }
                            }
                        }
                }
            } else if tagHeight == 1{
                //목표시간이 1시간이고
                if originalHeight > 36 {
                        //현재시간이 1시간 반 이상일때
                        let insertCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                        for i in 1...insertCount {
                            if selectedTagIndex + i < combinedTags.count {
                                combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear),at: selectedTagIndex + i)
                            }
                        }
                } else if originalHeight < 36 {
                    //현재시간 30분일때
                        //현재시간이 30분일때
                        combinedTags.remove(at: selectedTagIndex + 1)
                    
                }
            } else if tagHeight < 1 {
                //목표시간이 30분일때
                if originalHeight == 36 {
                        //현재시간이 1시간일때
                        combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear),at: selectedTagIndex + 1)
                    
                }
                else if originalHeight > 36 {
                        //현재시간이 1시간30분 이상일떄
                        let insertCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                        for i in 1...insertCount {
                            if selectedTagIndex + i < combinedTags.count {
                                combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: .clear, height: 18, fontColor: .clear),at: selectedTagIndex + i)
                            }
                        }
                }
            }
        }
        combinedTags[selectedTagIndex].height = CGFloat(tagHeight * 36)
        
    }
    
    func startSingleTimer() {
        taskManager.executeTask {
            print("Start Reset")
            secTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                timeSpentInView += 1
                print(timeSpentInView)
                if timeSpentInView >= threshold {
                    // 임계값 이상으로 머무른 경우 print
                    print("User spent more than \(threshold) seconds in this view.")
                    copyedCombinedTags = combinedTags
                    for index in (0..<copyedCombinedTags.count) {
                        if !copyedCombinedTags[index].text.isEmpty{
//                                    continue
                            copyedCombinedTags[index] = Tag(text: copyedCombinedTags[index].text, color: copyedCombinedTags[index].color, height: copyedCombinedTags[index].height, fontColor: copyedCombinedTags[index].fontColor)

                        }
                        copyedCombinedTags[index] = Tag(text: "12345", color: .clear, height: 18, fontColor: .clear)
                    }
//                    copyedCombinedTags = combinedTags
                    secTimer?.invalidate() // 타이머 중지
                    timeSpentInView = 0
                    escape = false
                    
                }
            }
        }
    }
    func stopSingleTimer() {
        // 타이머 중지
        taskManager.cancelTask()
        secTimer?.invalidate()
        timeSpentInView = 0
        
    }
    
    //MARK: - Class
    class TaskManager {
        private var currentTask: DispatchWorkItem?
        
        func executeTask(_ task: @escaping () -> Void) {
            // 이전 작업이 있는 경우 취소
            currentTask?.cancel()
            
            // 새 작업 생성
            let newTask = DispatchWorkItem {
                task()
            }
            
            // 현재 작업 업데이트
            currentTask = newTask
            
            // 새 작업 실행
            DispatchQueue.main.async(execute: newTask)
        }
        func cancelTask() {
            // 현재 작업이 있는 경우 취소
            currentTask?.cancel()
        }
    }
    
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
        @Binding var tagView: Bool
        @Binding var draggedTag : Tag?
        
        func performDrop(info: DropInfo) -> Bool {
            
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }
            
            itemProvider.loadObject(ofClass: String.self) { (text, error) in
                if let text = text as? String {
                    var droppedTag = MyTripLog.addTag(text: text, fontSize: 16)
                    
                    let location = info.location
                    let index = Int(floor(location.y / (18)))
                    //location과 index 보완 필요
                    
                    if index >= 0 && index < combinedTags.count , combinedTags[index].text.isEmpty {
                        //Tag 덮어씌우지 못하도록 처리
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
            tagView = false
            print("drop")
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
