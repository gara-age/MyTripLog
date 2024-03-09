//
//  AddTagView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI
import SwiftData

struct AddTagView: View {
    @Environment(\.undoManager) var undoManager

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var allTravels: [Travel]
    @Query(animation: .snappy) private var allTags: [Tag]
    @StateObject var tagManager = TagManager()

    @State private var travel : Travel?
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
    @State private var draggedTag: Tag?
    @State private var dropDone : Bool = true
    @State private var escape = false
    @State private var forCheck : Int = 0
    let taskManager = TaskManager()
    @State private var secTimer: Timer?
    @State private var timeSpentInView: TimeInterval = 0
    let threshold: TimeInterval = 5
    let thresLongWaithold: TimeInterval = 10
    @State private var deleteDayRequest : Bool = false
    @State private var forReset : Bool = false
    @Binding var nameText : String
    @Binding var moveToATV : Bool
    @State private var cancelRequest = false
    @State private var editedTrip : Travel = Travel(title: "", startDate: Date(), endDate: Date(), startTime: 0, endTime: 0, imageString: "")
    @State private var isEditTitle : Bool = false
    @State private var saveTag : Bool = false
    @State private var copiedTravel : Travel?
    @State private var copiedTags : [Tag] = []
    @State private var undoCount : Int = 0
    
    var body: some View {
        
        NavigationStack{
            VStack{
                //MARK: -TagView
                
                ScrollView(.vertical){
                    TagView(tagManager: tagManager, tags: $tags, draggedTag: $draggedTag, tagText: $tagText, tagView: $tagView, editMode: $editMode, originalText: $originalText, getTagColor: $getTagColor, dropDone: $dropDone, escape: $escape, cancelFunction: stopTimer, cancelByWaitFunction: cancelByWaitFunction, nameText: $nameText, moveToATV: $moveToATV, saveTag: $saveTag,  updateTags: updateTags, undoCount: $undoCount)
                }
                .onTapGesture{
                    tagView = false
                    dropDone = true
                }
                .if(tagView && !dropDone){ RowView in
                    RowView
                        .dropDestination(for: String.self) { items, location in
                            tagView = false
                            dropDone = true
                            return false
                        } isTargeted: { status in
                            if let draggedTag, status, draggedTag != tags[0] {
                                
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                
                HStack{
                    TextField("새로운 일정명을 입력하세요.", text: $text)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.textFG)
                                .strokeBorder(Color("Tag").opacity(0.2), lineWidth: 1)

                        )

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
                        
                    }
                    
                }
                
            }
           
            .onChange(of: !tagView){
                if !tagView {
                    stopTimer()
                }
            }
            .frame(maxWidth: .infinity)
            .blur(radius: editMode || setHeight ? 5 : 0)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        cancelRequest.toggle()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(moveToATV ? "추가" : "저장") {
                        saveTag.toggle()
                       saveMaxDays()
                    }
                    .tint(.blue)
                }
                ToolbarItem(placement: .principal) {
                    HStack{
                        Text(editedTrip.title.isEmpty ? nameText : editedTrip.title)
                        if moveToATV {
                            Button{
                                editTitle()
                            }
                        label: {
                            Image(systemName: "pencil")
                                .font(.headline)
                               

                        }
                    }
                }
                                   }
            }
            
        }
        .sheet(isPresented: $isEditTitle) {
            EditTitleView(selectedTrip: $editedTrip)
        }
        .onChange(of: undoCount){
            print("undoCount is \(undoCount)")
        }

        .alert("저장되지않은 사항은 유지되지않습니다. 여정에서 벗어나시겠습니까?", isPresented: $cancelRequest) {
            Button(role: .destructive) {
                dismiss()
                if moveToATV {

                            undoManager?.undo()

                }
                if !moveToATV {
                print("\(undoCount) is undoCount")
                    if undoCount > 0 {
                        for i in 1...undoCount + 1 {
                            undoManager?.undo()
                        }
                    }
                }

            } label: {
                Text("나가기")
            }
            
            Button(role: .cancel) {
            } label: {
                Text("취소")
            }
        }
        .onChange(of: editedTrip.title){
            if !editedTrip.title.isEmpty {
                nameText = editedTrip.title
            }
        }
        .onAppear{
            if !moveToATV {
                //Travel 의 maxDayIndex 확인하여 처리
                if let foundTravel = allTravels.first(where: { $0.title == nameText }) {
                    travel = foundTravel
                }
                if travel?.maxDayIndex ?? 0 > 0 {
                    currentDayIndex = (travel?.maxDayIndex)!
                }
            }
        }
        .onDisappear{
            moveToATV = false
            saveTag = false
            tagManager.combinedTags.removeAll()
            tagManager.tags.removeAll()
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
                    undoCount += 1
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
                        undoCount += 1

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
                            undoCount += 1

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
    func copyTags() {
     
        let foundTags = allTags.filter( { $0.travelTitle == nameText})
        let copyTags = foundTags
        copiedTags = copyTags
    }
    

    func saveMaxDays() {
        if let foundTravel = allTravels.first(where: { $0.title == nameText }) {
            travel = foundTravel
        }
        let originalDayIndex = travel?.maxDayIndex ?? 0

        travel?.maxDayIndex = currentDayIndex
        
        if travel?.maxDayIndex ?? 0 < originalDayIndex {

            let tagsWillDelete = allTags.filter {  $0.travelTitle == nameText && (travel?.maxDayIndex)! < originalDayIndex && $0.dayIndex != 100 && $0.dayIndex! > (travel?.maxDayIndex)!}
            DispatchQueue.main.async{
                for tag in tagsWillDelete {
                    context.delete(tag)
                }
            }
        } else {
            travel?.maxDayIndex = currentDayIndex
        }
        DispatchQueue.main.async{
            
            try! context.save()
        }
        dismiss()
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
                DaysTagView(tags: getTagBinding(for: index), tagView: $tagView, setHeight: $setHeight, tagText: $tagText, tagColor: $tagColor, tagHeight: $tagHeight, tagID: $tagID, getTagColor: $getTagColor, startTime: startTime, endTime: endTime, tagTime: $tagTime,draggedTag: $draggedTag, dropDone: $dropDone, escape: $escape, startFunction: startTimer , cancelFunction: stopTimer, forReset: $forReset, originalDayIndex: index, nameText: $nameText, moveToATV: $moveToATV, saveTags: $saveTag, currentDayIndex: $currentDayIndex,tagManager: tagManager, undoCount: $undoCount)
                
                    .frame(height: geometry.size.height)
            }
        }
        .background(.daysBG)

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
        .contentShape(.rect)
    }
    func editTitle() {
        if let foundTravel = allTravels.first(where: { $0.title == nameText }) {
            editedTrip = foundTravel
                }
        isEditTitle.toggle()
    }
    func saveTags() {
        NotificationCenter.default.post(
            name: Notification.Name("saveTag"),
            object: ["TravelTitle" : nameText])

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
