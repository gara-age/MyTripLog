//
//  Home.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI
import SwiftData

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
    @Binding var startTime : Int
    @Binding var endTime : Int
    @State private var tagSizeUpdatedNotificationReceived = false
    @State private var draggedTag: Tag?
    @State private var dropDone : Bool = true
    @State private var escape = false
    @State private var forCheck : Int = 0
    let taskManager = TaskManager()
    @State private var secTimer: Timer?
    @State private var timeSpentInView: TimeInterval = 0
    let threshold: TimeInterval = 5
    let thresLongWaithold: TimeInterval = 10
    @State private var shownDayIndex : Int = 0
    @State private var deleteDayRequest : Bool = false
    @State private var forReset : Bool = false
    @Binding var nameText : String

    var body: some View {
        NavigationStack{
            VStack{
                //MARK: -TagView
                
                ScrollView(.vertical){
                    TagView(tags: $tags, draggedTag: $draggedTag, tagText: $tagText, tagView: $tagView, editMode: $editMode, originalText: $originalText, getTagColor: $getTagColor, dropDone: $dropDone, escape: $escape, cancelFunction: stopTimer, cancelByWaitFunction: cancelByWaitFunction, updateTags: updateTags)
                }
                .onTapGesture{
                    tagView = false
                    dropDone = true
                }
                .if(tagView && !dropDone){ RowView in
                    RowView
                        .dropDestination(for: String.self) { items, location in
                            print("return false")
                            tagView = false
                            dropDone = true
                            return false
                        } isTargeted: { status in
                            if let draggedTag, status, draggedTag != tags[0] {
                                
                            }
                        }
                }
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity)
                .clipped()
                
                HStack{
                    TextField("새로운 일정명을 입력하세요.", text: $text)
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
                        Text("추가")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("BGColor"))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 45)
                            .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tags.contains(where: { $0.text == text }) ? Color.gray : Color("Tag"))
                            .cornerRadius(10)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tags.contains(where: { $0.text == text }))
                    
                    
                }
                .if(tagView && !dropDone){ RowView in
                    RowView
                        .dropDestination(for: String.self) { items, location in
                            print("return false")
                            tagView = false
                            dropDone = true
                            return false
                        } isTargeted: { status in
                            if let draggedTag, status, draggedTag != tags[0] {
                                
                            }
                        }
                }
                .padding(.horizontal, 7)
            }
            .background(.ultraThinMaterial)
            .blur(radius: editMode || setHeight ? 5 : 0)
            
            ScrollView(.vertical,showsIndicators: false){
                HStack{
                    VStack {
                        Spacer(minLength: fontSize + 21)
                        ForEach(startTime..<endTime) { hour in
                            VStack(spacing:10) {
                                Text("\(String(format: "%02d", hour)):00")
                                
                                Divider()
                                    .frame(height: 0.1)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onTapGesture{
                        tagView = false
                        dropDone = true
                    }
                    .if(tagView && !dropDone){ RowView in
                        RowView
                            .dropDestination(for: String.self) { items, location in
                                print("return false")
                                tagView = false
                                dropDone = true
                                return false
                            } isTargeted: { status in
                                if let draggedTag, status, draggedTag != tags[0] {
                                    
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
            .onChange(of: !tagView){
                if !tagView {
                    stopTimer()
                }
            }
            .onChange(of: currentDayIndex){
                shownDayIndex = currentDayIndex
            }
            .frame(maxWidth: .infinity)
            
            .blur(radius: editMode || setHeight ? 5 : 0)
            
            .navigationTitle(nameText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
//                        dismiss()
                    }
                    .tint(.blue)
                }
            }
            
        }
        .interactiveDismissDisabled()

        .disabled(editMode || setHeight)
        .overlay(
            ColorPicker("", selection: $originalColor, supportsOpacity: false)
                .labelsHidden()
                .opacity(0)
                .onChange(of: originalColor) { newColor in
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
                        
                        // Reset the editedTag and editedText
                        DispatchQueue.main.async {
                            editedTag = nil
                            editedText = ""
                        }
                        
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
                        DispatchQueue.main.async {
                            updateSelectedTagTime(tagTime: tagTime)
                        }
                    }, onClose: {
                        setHeight = false
                        changeAll = false
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
        
        tagText = ""
        tagID = ""
        changeAll = false
        setHeight = false

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
                                                deleteDayRequest.toggle()
                                                
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
            .if(tagView && !dropDone){ RowView in
                RowView
                    .dropDestination(for: String.self) { items, location in
                        print("return false")
                        tagView = false
                        dropDone = true
                        return false
                    } isTargeted: { status in
                        if let draggedTag, status, draggedTag != tags[0] {
                            
                        }
                    }
            }
            .padding(.top, 10)
            GeometryReader { geometry in
                DaysTagView(tags: getTagBinding(for: index), tagView: $tagView, setHeight: $setHeight, tagText: $tagText, tagColor: $tagColor, tagHeight: $tagHeight, tagID: $tagID, getTagColor: $getTagColor, startTime: $startTime, endTime: $endTime, tagTime: $tagTime,draggedTag: $draggedTag, dropDone: $dropDone, escape: $escape, startFunction: startTimer , cancelFunction: stopTimer, dayIndex: $shownDayIndex, forReset: $forReset)
                
                    .frame(height: geometry.size.height)
            }
        }
        .alert("해당 일자에 포함된 모든 일정이 삭제됩니다. 정말 삭제하시겠습니까?", isPresented: $deleteDayRequest) {
            Button(role: .destructive) {
                withAnimation {
                    deleteDay(at: index)
                }
                deleteDayRequest = false
            } label: {
                Text("삭제")
            }
            
            Button(role: .cancel) {
                deleteDayRequest = false
            } label: {
                Text("취소")
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
    
    func startCancel() {
        escape = true
        tagView = false
        dropDone = true
    }
    
    func startTimer() {
        taskManager.executeTask {
            secTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                timeSpentInView += 1
                if timeSpentInView >= threshold {
                    //한 데테뷰에서 10초 머무를 경우
                    startCancel()
                    // 여기에서 원하는 추가 동작을 수행할 수 있습니다.
                    secTimer?.invalidate() // 타이머 중지
                    timeSpentInView = 0
                    escape = false
                    
                }
            }
        }
    }
    func cancelByWaitFunction() {
        taskManager.executeTask {
            secTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                timeSpentInView += 1
                if timeSpentInView >= thresLongWaithold {
                    //태그뷰에서 드래그 시작 후 5초 머무를 경우
                    startCancel()

                    // 여기에서 원하는 추가 동작을 수행할 수 있습니다.
                    secTimer?.invalidate() // 타이머 중지
                    timeSpentInView = 0
                    escape = false
                    
                }
            }
        }
    }
    func stopTimer() {
        // 타이머 중지
        escape = false
        
        taskManager.cancelTask()
        secTimer?.invalidate()
        timeSpentInView = 0
        
    }
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
        func longWaitExecuteTask(_ task: @escaping () -> Void) {
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
            currentTask = nil
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
