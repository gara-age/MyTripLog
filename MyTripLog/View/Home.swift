//
//  Home.swift
//  MyTripLog
//
//  Created by 최민서 on 1/5/24.
//

import SwiftUI

struct Home: View {
    
    //Sample Tasks
    
    @State private var todo : [Task] = [
        .init(title: "Edit Video!", status: .todo)
    ]
    @State private var working : [Task] = [
        .init(title: "record Video", status: .working)
    ]
    @State private var completed : [Task] = [
        .init(title: "Implement Drag & Drop", status: .completed),
        .init(title: "Update MockView Video", status: .completed),
    ]
    //View properties
    @State private var currentlyDragging : Task?
    
    var body: some View {
        HStack(spacing: 2){
            TodoView()
            
            WorkingView()
    
            CompletedView()
               
            
        }
    }
    //Tasks View
    @ViewBuilder
    func TasksView(_ tasks: [Task]) -> some View  {
        VStack(alignment: .leading, spacing: 10, content: {
            ForEach(tasks) { task  in
                GeometryReader {
                    //Task Row
                    TaskRow(task, $0.size)
                }
                .frame(height: 45)
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
                        case .todo:
                            replaceItem(tasks: &todo, droppingTask: task, status: .todo)
                        case .working:
                            replaceItem(tasks: &working, droppingTask: task, status: .working)
                        case .completed:
                            replaceItem(tasks: &completed, droppingTask: task, status: .completed)
                        }
                    }
                }
            }

    }
    
    //Appending and Removing task from one list to another list
    func appendTask(_ status: Status) {
        if let currentlyDragging {
            switch status {
            case .todo:
                //Safe check and inserting into List
                if !todo.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .todo
                    //Adding to the List
                    todo.append(updatedTask)
                    //Removing it from all other List
                    working.removeAll(where: {$0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})

                }
            case .working:
                if !working.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .working
                    //Adding to the List
                    working.append(updatedTask)
                    //Removing it from all other List
                    todo.removeAll(where: {$0.id == currentlyDragging.id})
                    completed.removeAll(where: {$0.id == currentlyDragging.id})

                }
            case .completed:
                if !completed.contains(where: {$0.id == currentlyDragging.id}) {
                    //updating it's status
                    var updatedTask = currentlyDragging
                    updatedTask.status = .completed
                    //Adding to the List
                    completed.append(updatedTask)
                    //Removing it from all other List
                    todo.removeAll(where: {$0.id == currentlyDragging.id})
                    working.removeAll(where: {$0.id == currentlyDragging.id})

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
    func TodoView() -> some View{
        NavigationStack{
            ScrollView(.vertical) {
                TasksView(todo)
            }
            .navigationTitle("Todo")
            .navigationBarTitleDisplayMode(.inline)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .contentShape(.rect)
            .dropDestination(for: String.self) { items, location in
                //Appending to the last of the current List, if the item is not present on that list
                withAnimation(.snappy){
                    appendTask(.todo)
                }
                return true
            } isTargeted: { _ in
                
            }
            
        }
    }
    //Working View
    @ViewBuilder
    func WorkingView() -> some View{
    NavigationStack{
        ScrollView(.vertical) {
            TasksView(working)
        }
        .navigationTitle("Working")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        .dropDestination(for: String.self) { items, location in
            //Appending to the last of the current List, if the item is not present on that list
            withAnimation(.snappy){
                appendTask(.working)
            }
            return true
        } isTargeted: { _ in
            
        }
    }
}
    //Completed View
    @ViewBuilder
    func CompletedView() -> some View{
    NavigationStack{
        ScrollView(.vertical) {
            TasksView(completed)
        }
        .navigationTitle("Completed")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .contentShape(.rect)
        .dropDestination(for: String.self) { items, location in
            //Appending to the last of the current List, if the item is not present on that list
            withAnimation(.snappy){
                appendTask(.completed)
            }
            return true
        } isTargeted: { _ in
            
        }
    }
}
}

#Preview {
    ContentView()
}
