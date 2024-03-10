//
//  DaysTagView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI
import Foundation
import SwiftData

struct DaysTagView: View {
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allTravels: [Travel]
    @Query(animation: .snappy) private var allTags: [Tag]
    @ObservedObject var tagManager: TagManager
    
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
    let startTime : Int
    let endTime : Int
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

    @State private var totalHeight: CGFloat = 0
    @State private var copiedCombinedTags: [Tag]
    @Binding var forReset : Bool
    let originalDayIndex : Int
    @State private var travel: Travel?
    @Binding var nameText : String
    @State private var stopFetching = false
    @Binding var moveToATV : Bool
    @Binding var saveTag : Bool
    @Binding var currentDayIndex : Int
    @Binding var undoCount : Int

    init(tags: Binding<[Tag]>, tagView: Binding<Bool>, setHeight: Binding<Bool>, tagText: Binding<String>, tagColor: Binding<Color>, tagHeight: Binding<CGFloat>, tagID: Binding<String>, getTagColor: Binding<Color>, startTime: Int, endTime: Int, tagTime: Binding<CGFloat>,draggedTag: Binding<Tag?>, dropDone: Binding<Bool>, escape: Binding<Bool>, startFunction: @escaping () -> Void, cancelFunction: @escaping () -> Void,  forReset: Binding<Bool>, originalDayIndex: Int, nameText: Binding<String>, moveToATV: Binding<Bool>, saveTags: Binding<Bool>, currentDayIndex: Binding<Int>,tagManager: TagManager, undoCount: Binding<Int>) {
        self._tags = tags
        self._tagView = tagView
        self._setHeight = setHeight
        self._tagText = tagText
        self._tagColor = tagColor
        self._tagHeight = tagHeight
        self._tagID = tagID
        self._getTagColor = getTagColor
        self.startTime = startTime
        self.endTime = endTime
        self._tagTime = tagTime
        self._draggedTag = draggedTag
        self._dropDone = dropDone
        self._escape = escape
        self.startFunction = startFunction
        self.cancelFunction = cancelFunction
        self._forReset = forReset
        self.originalDayIndex = originalDayIndex
        self._nameText = nameText
        self._moveToATV = moveToATV
        self._saveTag = saveTags
        self.tagManager = tagManager
        self._currentDayIndex = currentDayIndex
        self._undoCount = undoCount
        let repeatCount = (startTime - endTime) * 2
        let tagRepeatCount: Int
        if repeatCount < 0 {
            tagRepeatCount = -repeatCount
        } else {
            tagRepeatCount = repeatCount
        }
        self._emptyTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "12345", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), count: 100).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "12345", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
        })
        self._combinedTags = State(initialValue: Array(repeating:   Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), count: tagRepeatCount).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
        } + tags.wrappedValue)
        self._copiedCombinedTags = State(initialValue: Array(repeating:   Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), count: tagRepeatCount).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
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
                        }
                    }
                    .frame(width: 150, alignment: .center)
                    
                }
                .scrollDisabled(true)
                .frame(maxWidth: .infinity)
            }
            
            .onAppear{
                for tag in combinedTags {
                    totalHeight += tag.height
                }
            }
            //MARK: - Overlay
            
            .overlay{
                
                ZStack {
                    if tagView && !dropDone {
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            let columns = Array(repeating: GridItem(spacing: 1), count: 1)
                            
                            LazyVGrid(columns: columns, spacing: 0.65) {
                                ForEach(copiedCombinedTags.indices, id: \.self) { index in
                                    CopyRowView(tag: copiedCombinedTags[index], index: index)
                                        .if(!copiedCombinedTags[index].text.isEmpty) {
                                            $0
                                                .padding(.vertical, 0 )
                                        }
                                        .if(tagView && !dropDone){ RowView in
                                            RowView
                                                .dropDestination(for: String.self) { items, location in
                                                    cancelFunction()
                                                    if currentDayIndex >= 1 {
                                                        stopSingleTimer()
                                                    }
                                                    let droppedTag = MyTripLog.addTag(text: draggedTag!.text, fontSize: 16)
                                                    if lastIndex >= 0 && lastIndex < combinedTags.count , combinedTags[lastIndex].text.isEmpty {
                                                        combinedTags.insert(droppedTag, at: lastIndex)

                                                        tagManager.combinedTags.append(droppedTag)
                                                        
                                                        combinedTags.remove(at: lastIndex + 1)
                                                        
                                                        if lastIndex + 1 < combinedTags.count, combinedTags[lastIndex + 1].text.isEmpty {
                                                            combinedTags.remove(at: lastIndex + 1)
                                                        }
                                                        
                                                        let originalColor = tags.first { $0.text == draggedTag!.text }?.color ?? getTagColor.toHex()
                                                        droppedTag.color = originalColor
                                                    }
                                                    
                                                    
                                                    draggedTag = nil
                                                    dropDone = true
                                                    tagView = false
                                                    escape = false
                                                    
                                                    return false
                                                } isTargeted: { status in
                                                    
                                                    let draggedTag = self.draggedTag
                                                    if let draggedTag, status, draggedTag != copiedCombinedTags[index] {
                                                        
                                                        cancelFunction()
                                                        stopSingleTimer()
                                                        
                                                        if index == 0 {
                                                            copiedCombinedTags[0] = draggedTag
                                                        }
                                                        if copiedCombinedTags[0].text == "12345" {
                                                            copiedCombinedTags[0] = draggedTag
                                                        }
                                                        if let sourceIndex = copiedCombinedTags.firstIndex(of: draggedTag),
                                                           let destinationIndex = copiedCombinedTags.firstIndex(of: copiedCombinedTags[index]) {
                                                            
                                                            let sourceItem = copiedCombinedTags.remove(at: sourceIndex)
                                                            for index in (0..<copiedCombinedTags.count) {
                                                                
                                                                copiedCombinedTags[index] = Tag(text: "12345", color: "#F4FAFC", height: combinedTags[index].height, fontColor: "#F4FAFC")
                                                                
                                                                
                                                            }
                                                            if destinationIndex > 0 , combinedTags[destinationIndex + 1].height >= 36 {
                                                                copiedCombinedTags.insert(sourceItem, at: destinationIndex + 1)
                                                            }
                                                            else if destinationIndex > 0 {
                                                                copiedCombinedTags.insert(sourceItem, at: destinationIndex)
                                                            }
                                                            else {
                                                                copiedCombinedTags.insert(sourceItem, at: destinationIndex)
                                                            }
                                                            lastIndex = destinationIndex
                                                            startFunction()
                                                            if currentDayIndex > 0 {
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
                            copiedCombinedTags = combinedTags
                            for index in (0..<copiedCombinedTags.count) {
                                if !copiedCombinedTags[index].text.isEmpty{
                                    copiedCombinedTags[index] = Tag(text: copiedCombinedTags[index].text, color: copiedCombinedTags[index].color, height: copiedCombinedTags[index].height, fontColor: copiedCombinedTags[index].fontColor)
                                    
                                }
                                copiedCombinedTags[index] = Tag(text: "12345", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
                            }
                            
                        }
                        .scrollDisabled(true)
                        
                    }
                }
                
                .onChange(of: escape) {
                    if escape {
                        emptyTags[lastIndex] = Tag(text: "12345", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
                        
                    }
                }
                .onChange(of: tagView) {
                    if !tagView {
                        stopSingleTimer()
                    }
                }
                
            } //overlay 끝
        }

        .onChange(of: saveTag){
            if saveTag {
                findDeletedTag()
            }
        }
      
        .onDisappear{
            stopFetching = false
        }
    }
    //MARK: - RowView
    
    @ViewBuilder
    func RowView(tag: Tag, index: Int) -> some View {
        HStack {
            let paddingCount = ((combinedTags[index].height / 18) - 0) / 5.5
            
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
                        .fill(tag.text.isEmpty ? Color.clear :  Color(hex: tag.color))
                        .frame(width: 150)
                        .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                )
                .foregroundColor(tag.text.isEmpty ? Color.clear : Color(hex:tag.fontColor))
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                    if !tag.text.isEmpty {
                        Button("시간 변경") {
                            DispatchQueue.main.async {
                                tagID = tag.id
                                tagHeight = tag.height
                                tagTime = tagHeight / 36
                                
                                tagColor = Color(hex: tag.color)
                                tagText = tag.text
                                setHeight = true
                            }
                            
                            //if 태그들의 height == viewHeight {시간변경에서 +는 불가 처리 및 잔여시간 없음 안내, 일괄로 처리도 불가한 일정 외에 변경 됩니다 or 불가한 일정이 있어 처리가 어렵습니다}
                            //일정이 꽉찬 DaysTagView에 tagText와 일치하는 Tag가 없을 경우 일괄 처리 가능
                            
                        }
                        Button("삭제") {
                            if let tagIndex = combinedTags.firstIndex(of: tag) {
                                let insertCount = Int(tag.height / 18)
                                
                              
                                if let findIndex = tagManager.combinedTags.firstIndex(of: tag){
                                    tagManager.combinedTags.remove(at: findIndex)
                                }
                                combinedTags.remove(at: tagIndex)

                                for _ in 0..<insertCount {
                                    combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), at: tagIndex)
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
                                            if combinedTags[index].text == tagText {
                                                let originalHeight = combinedTags[index].height
                                                
                                                updateTagHeight(selectedTagIndex: index, originalHeight: originalHeight, tagHeight: tagHeight)
                                                
                                            }
                                            
                                        }
                                    }
                                } else {
                                    if let selectedTagIndex = combinedTags.firstIndex(where: { $0.text == tagText && $0.id == tagID }) {
                                        let originalHeight = combinedTags[selectedTagIndex].height
                                        
                                        updateTagHeight(selectedTagIndex: selectedTagIndex, originalHeight: originalHeight, tagHeight: tagHeight)
                                        
                                    }
                                }
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagColorChanged"))) { notification in
                            if let userInfo = notification.object as? [String: Any],
                               let color = userInfo["color"] as? Color,
                               let originalText = userInfo["originalText"] as? String {
                                
                                combinedTags = combinedTags.map { existingTag in
                                    if existingTag.text == originalText {
                                        let updatedTag = existingTag
                                        updatedTag.color = color.toHex()
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
                                
                                if let index = combinedTags.firstIndex(where: { $0.text == originalText }) {
                                    
                                    combinedTags[index].text = newText
                                }
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagDeleted"))) { notification in
                            if let deletedTag = notification.object as? Tag {
                                let copyDeletedTag = deletedTag
                                
                                let tagsWithSameText = combinedTags.filter { $0.text == copyDeletedTag.text }
                                
                                for tagWithSameText in tagsWithSameText {
                                    if let originalHeight = tagWithSameText.height as CGFloat? , originalHeight > 18 {
                                        
                                        let insertCount = Int(originalHeight / 18) - 1
                                        if let tagIndex = combinedTags.firstIndex(where: { $0.text == tagWithSameText.text && $0.id == tagWithSameText.id }) {
                                            for _ in 0..<insertCount + 1 {
                                                combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), at: tagIndex)
                                            }
                                        }
                                    }
                                }
                                
                                removeTag(withText: deletedTag.text, from: &combinedTags)
                            }
                        }
                }
            
            
        }
        .onAppear{
            if !tag.text.isEmpty {
                let findSameTag = tagManager.combinedTags.contains(where: { $0.id == tag.id })
                guard !findSameTag else { return }
                tagManager.combinedTags.append(tag)
            }
            if !tag.text.isEmpty {
            
            }
        }
        .if(!tag.text.isEmpty) {
            $0
                .draggable(tag.text) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .frame(width: 1, height: 1)
                    .onAppear {
                        draggedTag = tag
                        tagView = false
                    }
            }
            .onChange(of: saveTag){
                if saveTag {
                    saveFunction(tag: tag, index: index)
                }
            }
        }
        .if(tag.text.isEmpty){
            $0
                .onAppear{
                    if !moveToATV{
                        loadTags(index: index, dayIndex: originalDayIndex)
                    }
                }
        }
   

    }
    
    @ViewBuilder
    func CopyRowView(tag: Tag, index: Int) -> some View {
        if index == 0 {
            HStack {
                let draggedTag = draggedTag
                let paddingCount = ((copiedCombinedTags[index].height / 18) - 0) / 5.5
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
                            .fill(tag.text.isEmpty || tag.text == "12345" ? tag.height > 18 ? Color.clear : Color.clear :  Color(hex:tag.color))
                            .frame(width: 150)
                            .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                    )
                    .foregroundColor(.clear)
                    .lineLimit(nil)
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            
        } else {
            HStack {
                let draggedTag = draggedTag
                let paddingCount = ((copiedCombinedTags[index].height / 18) - 0) / 5.5
                
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
                            .fill(tag.text.isEmpty || tag.text == "12345" ? tag.height > 18 ? Color.clear : Color.clear :  Color(hex: tag.color))
                            .frame(width: 150)
                            .frame(height: tag.text.isEmpty ? 18 : tag.height <= 36 ? tag.height : tag.height + paddingCount)
                    )
                    .foregroundColor(.clear)
                    .lineLimit(nil)
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            
        }
        
    }
    
    //MARK: - Function
    
    func saveFunction(tag: Tag, index: Int) {
           
                let existingTags = allTags.filter { $0.travelTitle == nameText && $0.dayIndex == originalDayIndex }
                let isTagExist = existingTags.contains(where: { $0.id == tag.id })
                if isTagExist {
                    
                    if let existingTag = existingTags.first(where: { $0.id == tag.id && $0.text == tag.text }) {

                        DispatchQueue.main.async{
                            
                            if !tag.text.isEmpty {
                                existingTag.rowIndex = index
                                try! context.save()
                                
                            }
                        }
                    }
                } else  if !isTagExist {

                    let isNewTag = !existingTags.contains(where: { $0.id == tag.id })
                    if isNewTag {
                        if !tag.text.isEmpty {

                        if let foundTravel = allTravels.first(where: { $0.title == nameText }) {
                            travel = foundTravel
                        }
                        let savedTag = Tag(id: tag.id, text: tag.text, color: tag.color, height: tag.height, fontColor: tag.fontColor, travel: travel, travelTitle: nameText, dayIndex: originalDayIndex, rowIndex: index)
                            DispatchQueue.main.async{
                                context.insert(savedTag)
                                try! context.save()
                            }
                        }
                    }
                }
                
    }
    
    func findDeletedTag() {
    
        let existingTags = allTags.filter { $0.travelTitle == nameText && $0.dayIndex == originalDayIndex }
            let tagsOnlyInExistingTags = existingTags.filter { existingTag in
                !combinedTags.contains { combinedTag in
                    
                    return existingTag.id == combinedTag.id
                }
            }
        DispatchQueue.main.async{
            
            for tagWillDelete in tagsOnlyInExistingTags {
                if !tagWillDelete.text.isEmpty {
                    context.delete(tagWillDelete)
                }
            }
        }
    }
    
    func loadTags(index: Int, dayIndex: Int) {
        guard !stopFetching else { return }
        let tagsPredicate = #Predicate<Tag> {
            ( $0.travelTitle == nameText ) && ( $0.dayIndex == originalDayIndex ) && ( $0.rowIndex == index )
        }
        
        let descriptor = FetchDescriptor<Tag>(predicate: tagsPredicate)
        
        do {
            let tags = try context.fetch(descriptor)
            
            DispatchQueue.main.async {
                
                tags.forEach { tag in
                    
                    if tag.rowIndex == index {
                        
                        if !tag.text.isEmpty {
                            
                            guard !combinedTags.contains(where: { $0.id == tag.id }) else {
                                return
                            }
                            
                            if combinedTags[index].text.isEmpty {
                                combinedTags[index] = tag
                                stopFetching = true
                                
                            }
                        }
                    }
                }
                
            }
        } catch {
            print("Cannot load combinedTags: \(error)")
        }
    }
    func updateTagHeight(selectedTagIndex: Int, originalHeight: CGFloat, tagHeight: Double) {
        
        
        let originalHeight = combinedTags[selectedTagIndex].height
        
        let tagOriginalHeight = originalHeight
   
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
                                if !combinedTags[selectedTagIndex + 1].text.isEmpty {

                                    break
                                }

                                combinedTags.remove(at: selectedTagIndex + 1)

                            }

                        }
                     
                    }

                }
                else if originalHeight > 36 {
                    var removalCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                    if removalCount < 0 {
                        removalCount = removalCount * -1
                        for i in 1...removalCount {
                            let nextIndex = selectedTagIndex + i
                            if nextIndex < combinedTags.count {

                                if !combinedTags[nextIndex].text.isEmpty {
                                    break
                                }
                                combinedTags.remove(at: nextIndex)
                            }

                        }
                    } else {
                        let insertCount = removalCount
                        if insertCount != 0 {
                            for i in 1...insertCount {
                                if selectedTagIndex + i < combinedTags.count {
                                    combinedTags.insert(Tag(text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"), at: selectedTagIndex + 1)
                                }

                            }
                        }
                    }
                } else if originalHeight < 36 {
                    var removalCount = Int((tagOriginalHeight - tagHeight * 36) / 18)

                    if removalCount < 0 {

                        removalCount = removalCount * -1
                        for i in 1...removalCount {
                            let nextIndex = selectedTagIndex + i
                            if nextIndex < combinedTags.count {
                                if !combinedTags[selectedTagIndex + 1].text.isEmpty {
                                    break
                                }

                                combinedTags.remove(at: selectedTagIndex + 1)

                            }
                            
                        }

                    }
                }
            } else if tagHeight == 1{
                if originalHeight > 36 {
                    let insertCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                    for i in 1...insertCount {
                        if selectedTagIndex + i < combinedTags.count {
                            combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"),at: selectedTagIndex + i)
                        }

                    }
                } else if originalHeight < 36 {
                    combinedTags.remove(at: selectedTagIndex + 1)

                }
            } else if tagHeight < 1 {
                if originalHeight == 36 {
                    combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"),at: selectedTagIndex + 1)

                }
                else if originalHeight > 36 {
                    let insertCount = Int((tagOriginalHeight - tagHeight * 36) / 18)
                    for i in 1...insertCount {
                        if selectedTagIndex + i < combinedTags.count {
                            combinedTags.insert(Tag(id: UUID().uuidString, text: "", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC"),at: selectedTagIndex + i)
                        }

                    }
                }
            }
        }
        combinedTags[selectedTagIndex].height = CGFloat(tagHeight * 36)
        
    }
    
    func startSingleTimer() {
        taskManager.executeTask {

            secTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                timeSpentInView += 1

                if timeSpentInView >= threshold {

                    copiedCombinedTags = combinedTags
                    for index in (0..<copiedCombinedTags.count) {
                        if !copiedCombinedTags[index].text.isEmpty{

                            copiedCombinedTags[index] = Tag(text: copiedCombinedTags[index].text, color: copiedCombinedTags[index].color, height: copiedCombinedTags[index].height, fontColor: copiedCombinedTags[index].fontColor)
                            
                        }
                        copiedCombinedTags[index] = Tag(text: "12345", color: "#F4FAFC", height: 18, fontColor: "#F4FAFC")
                    }
                    secTimer?.invalidate()
                    timeSpentInView = 0
                    escape = false
                    
                }
            }
        }
    }
    func stopSingleTimer() {
        
        taskManager.cancelTask()
        secTimer?.invalidate()
        timeSpentInView = 0
        
    }
    
    //MARK: - Class
    class TaskManager {
        private var currentTask: DispatchWorkItem?
        
        func executeTask(_ task: @escaping () -> Void) {

            currentTask?.cancel()
            
            let newTask = DispatchWorkItem {
                task()
            }
            
            currentTask = newTask
            
            DispatchQueue.main.async(execute: newTask)
        }
        func cancelTask() {

            currentTask?.cancel()
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
extension Color {
    func toHexString() -> String {
        guard let components = cgColor?.components else { return "Invalid Color" }
        guard components.count >= 3 else { return "Invalid Color" }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        var a = Int(components[3] * 255)
        
        if a == 255 {
            a = 0
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}


#Preview {
    ContentView()
}
