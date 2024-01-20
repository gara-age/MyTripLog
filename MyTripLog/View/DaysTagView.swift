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
    @State private var timeInt: Int = 16 // timeInt +1만큼 반복하도록
    @Namespace var animation

    init(tags: Binding<[Tag]>, tagView: Binding<Bool>) {
        self._tags = tags
        self._tagView = tagView
        self._combinedTags = State(initialValue: Array(repeating: Tag(id: UUID().uuidString, text: ""), count: 24).enumerated().map { index, _ in
            Tag(id: UUID().uuidString, text: "")
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
    
    @ViewBuilder
    func RowView(tag: Tag, index: Int) -> some View {
        HStack {
            Text(tag.text)
                .font(.system(size: fontSize))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tag.text.isEmpty ? Color.clear : Color.tag)
                        .frame(width: 150)
                )
                .foregroundColor(Color("BG"))
                .lineLimit(nil)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                              if !tag.text.isEmpty {
                                  Button("Delete") {
                                      if let tagIndex = combinedTags.firstIndex(of: tag) {
                                          combinedTags.remove(at: tagIndex)
                                      }
                                  }
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


    struct DaysTagViewDragDropDelegate: DropDelegate {
        @Binding var tags: [Tag]

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

       print("return false")

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
                    let droppedTag = MyTripLog.addTag(text: text, fontSize: 16)

                    // Find the location in the ScrollView
                    let location = info.location

                    // Calculate the index of the dropped empty row based on the location
                    let index = Int(floor(location.y / (16 + 20))) // Assuming the height of each row is fontSize + 20
//인식 영역의 색상을 변경시켜보기
                    // Ensure the index is within the bounds of the combinedTags array
                    if index >= 0 && index <= combinedTags.count {
                        // Remove the tag at the dropped index in combinedTags
                        combinedTags.remove(at: index)

                        // Insert the dropped tag at the dropped index in tags
                        tags.insert(droppedTag, at: index)
                        print("drop by TagView")
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
