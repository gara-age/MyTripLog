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
    
    init(tags: Binding<[Tag]>, tagView: Binding<Bool>) {
        self._tags = tags
        self._tagView = tagView
        self._combinedTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: "", color: .clear), count: 24).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "", color: .clear)
        } + tags.wrappedValue)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    let columns = Array(repeating: GridItem(spacing: 1), count: 1)

                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(combinedTags.indices, id: \.self) { index in
                            RowView(tag: combinedTags[index], index: index)
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
                                .frame(height: fontSize + 20)
                        }
                    }
                    .frame(width: 150, alignment: .center)
                }
   
                .scrollDisabled(true)
                .frame(maxWidth: .infinity)
                .onDrop(of: ["public.text"], delegate: tagView ? TagViewDragDropDelegate(tags: $combinedTags, combinedTags: $combinedTags) : DaysTagViewDragDropDelegate(tags: $combinedTags))
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
                    draggableText.padding(.horizontal, 150)
                }
                .if(!tag.text.isEmpty){  draggableText in
                    draggableText
                        .frame(width: 150, height: 36)

                }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tag.text.isEmpty ? Color.clear :  tag.color)
                        .frame(width: 150, height: 36)
                )
                .foregroundColor(Color("BG"))
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                              if !tag.text.isEmpty {
                                  Button("삭제") {
                                      if let tagIndex = combinedTags.firstIndex(of: tag) {
                                          combinedTags.remove(at: tagIndex)
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
                                            } else {
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

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

            // Get the dropped text
            itemProvider.loadObject(ofClass: String.self) { (text, error) in
                if let text = text as? String {
                    var droppedTag = MyTripLog.addTag(text: text, fontSize: 16)

                    // Find the location in the ScrollView
                    let location = info.location

                    // Calculate the index of the dropped empty row based on the location
                    let index = Int(floor(location.y / (16 + 20))) // Assuming the height of each row is fontSize + 20
                    // Ensure the index is within the bounds of the combinedTags array
                    if index >= 0 && index <= combinedTags.count {
                        // Remove the tag at the dropped index in combinedTags
                        combinedTags.remove(at: index)
                        let color = Color(hue: Double(text.hashValue % 100) / 100.0, saturation: 0.8, brightness: 0.8)

                        // Update the color of the dropped tag based on the original color
                        let originalColor = tags.first { $0.text == text }?.color ?? color
                        droppedTag.color = originalColor

                        // Insert the dropped tag at the dropped index in tags
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

    private func deleteEmptyTag(at index: Int) {
        combinedTags.remove(at: index)
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
