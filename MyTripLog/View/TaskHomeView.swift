//
//  TaskView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI

struct TaskView: View {
    
    //Sample Tasks
    @State private var allDay : [Task] = []
    @State private var day1 : [Task] = [
        .init(title: "Edit Video!", status: .day1),
     
    ]
    @State private var day2 : [Task] = [
        .init(title: "record Video", status: .day2)
    ]
    @State private var day3 : [Task] = [
        .init(title: "Implement Drag & Drop", status: .day3),
        .init(title: "Update MockView Video", status: .day3),
    ]
    @State private var day4 : [Task] = []
    //View properties
    @State private var currentlyDragging : Task?
    @State private var text : String = ""
    @State var tags: [Tag] = []
    @State private var title: String = "오사카 3박4일 여행"
    
    var body: some View {
                NavigationStack{
                        VStack{
                            ScrollView(.vertical){
//                                TagView(tags: $tags)
                                TasksView(allDay)
                                
                            }
                            .background(.green)
                            .clipped()
                            
                            HStack{
                                TextField("apple", text: $text)
                                    .font(.title3)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(Color("Tag").opacity(0.2), lineWidth: 1))
                                Button{
                                    // Adding Tag
                                    let newTask = Task(title: text, status: .allDay) // You can set the appropriate status
                                        allDay.append(newTask) // Assuming you want to add the new task to day1 list
                                        text = "" // C
                                } label: {
                                    Text("Add")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color("BG"))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 45)
                                        .background(Color("Tag"))
                                        .cornerRadius(10)
                                }
                            }
                        }
                                    
                        ScrollView(.vertical,showsIndicators: false){
                            HStack{
                                    VStack {
                                        Spacer(minLength: 20) //DayView의 text.height
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
                                            Day1View()                                                .frame(minWidth: 100)
                                            Day2View()
                                                .frame(minWidth: 100)
                                            Day3View()
                                                .frame(minWidth: 100)
                                            Day4View()
                                                .frame(minWidth: 100)
                                            
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
                
            }    //Tasks View
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View  {
        VStack(alignment: .leading, spacing: 10, content: {
            ForEach(tasks) { task  in
                GeometryReader {
                    //Task Row
                    TaskRow(task, $0.size)
                }
                .frame(height: 40)
            }
        })
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    func TaskRow(_ task: Task, _ size: CGSize) -> some View {
        Text(task.title)
            .font(.callout)
            .padding(.horizontal, 15) //내꺼롤 적용할땐 없애도 될듯
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: size.height)
            .background(.white, in: .rect(cornerRadius: 10))
            .contentShape(.dragPreview ,.rect(cornerRadius: 10))
            .draggable(task.id.uuidString){
                Text(task.title)
                    .font(.callout)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: size.width , height: size.height, alignment: .leading )
                    .background(.white)
                    .contentShape(.dragPreview ,.rect(cornerRadius: 10))
                    .onAppear(perform: {
                        currentlyDragging = task
                    })
            }
            .dropDestination(for: String.self) { items, location in
                currentlyDragging = nil
                return false
            } isTargeted: { status in
                if let currentlyDragging, status, currentlyDragging.id != task.id{
                    withAnimation(.snappy) {
                        appendTask(task.status)
                        //Implement cross List Interaction
                        
                        switch task.status {
                        case .allDay:
                            replaceItem(tasks: &day1, droppingTask: task, status: .allDay)
                        case .day1:
                            replaceItem(tasks: &day1, droppingTask: task, status: .day1)
                        case .day2:
                            replaceItem(tasks: &day2, droppingTask: task, status: .day2)
                        case .day3:
                            replaceItem(tasks: &day3, droppingTask: task, status: .day3)
                        case .day4:
                            replaceItem(tasks: &day4, droppingTask: task, status: .day4)
                            
                        }
                    }
                }
            }

    }
    
    //Appending and Removing task from one list to another list
    func appendTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
            case .allDay:
                //Safe check and inserting into List
                if !allDay.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .allDay
                    //Adding to the List
                    allDay.append(updatedTask)
                    //Removing it from all other List
                    day1.removeAll(where: {$0.id == currentlyDragging.id})
                    day2.removeAll(where: {$0.id == currentlyDragging.id})
                    day3.removeAll(where: {$0.id == currentlyDragging.id})
                    day4.removeAll(where: {$0.id == currentlyDragging.id})


                }
            case .day1:
                //Safe check and inserting into List
                if !day1.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .day1
                    //Adding to the List
                    day1.append(updatedTask)
                    //Removing it from all other List
                    day2.removeAll(where: {$0.id == currentlyDragging.id})
                    day3.removeAll(where: {$0.id == currentlyDragging.id})
                    day4.removeAll(where: {$0.id == currentlyDragging.id})


                }
            case .day2:
                if !day2.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .day2
                    //Adding to the List
                    day2.append(updatedTask)
                    //Removing it from all other List
                    day1.removeAll(where: {$0.id == currentlyDragging.id})
                    day3.removeAll(where: {$0.id == currentlyDragging.id})
                    day4.removeAll(where: {$0.id == currentlyDragging.id})

                }
            case .day3:
                if !day3.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .day3
                    //Adding to the List
                    day3.append(updatedTask)
                    //Removing it from all other List
                    day1.removeAll(where: {$0.id == currentlyDragging.id})
                    day2.removeAll(where: {$0.id == currentlyDragging.id})
                    day4.removeAll(where: {$0.id == currentlyDragging.id})

                }
            case .day4:
                if !day4.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .day4
                    //Adding to the List
                    day4.append(updatedTask)
                    //Removing it from all other List
                    day1.removeAll(where: {$0.id == currentlyDragging.id})
                    day2.removeAll(where: {$0.id == currentlyDragging.id})
                    day3.removeAll(where: {$0.id == currentlyDragging.id})

                }
            }
        }
    }
    
    //Replacing Items within Lists
    func replaceItem(tasks: inout [Task],droppingTask : Task, status: Status){
        if let currentlyDragging {
            if let sourceIndex = tasks.firstIndex(where: {$0.id == currentlyDragging.id}),
               let destinationIndex = tasks.firstIndex(where: {$0.id == droppingTask.id}){
                //Swapping items on the list
                var sourceItem = tasks.remove(at: sourceIndex)
                sourceItem.status = status
                tasks.insert(sourceItem, at: destinationIndex)
            }
        }
    }
    
    
        //Todo View
    @ViewBuilder
    func Day1View() -> some View{
        NavigationStack{
//            ScrollView(.vertical) {
                TasksView(day1)
            Spacer()
//            }
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                //Appending to the last of the current List, if the item is not present on that list
                withAnimation(.snappy){
                    appendTask(.day1)
                }
                return true
            } isTargeted: { _ in
                
            }
            
        }
    }
    //Working View
    @ViewBuilder
    func Day2View() -> some View{
    NavigationStack{
//        ScrollView(.vertical) {
            TasksView(day2)
        Spacer()
//        }
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        .dropDestination(for: String.self) { items, location in
            //Appending to the last of the current List, if the item is not present on that list
            withAnimation(.snappy){
                appendTask(.day2)
            }
            return true
        } isTargeted: { _ in
            
        }
    }
}
    //Completed View
    @ViewBuilder
    func Day3View() -> some View{
    NavigationStack{
//        ScrollView(.vertical) {
            TasksView(day3)
        Spacer()
//        }
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        .dropDestination(for: String.self) { items, location in
            //Appending to the last of the current List, if the item is not present on that list
            withAnimation(.snappy){
                appendTask(.day3)
            }
            return true
        } isTargeted: { _ in
            
        }
    }
}
    @ViewBuilder
    func Day4View() -> some View{
    NavigationStack{
//        ScrollView(.vertical) {
            TasksView(day4)
        Spacer()
//        }
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        .dropDestination(for: String.self) { items, location in
            //Appending to the last of the current List, if the item is not present on that list
            withAnimation(.snappy){
                appendTask(.day4)
            }
            return true
        } isTargeted: { _ in
            
        }
    }
}
}

#Preview {
    TaskView()
}
