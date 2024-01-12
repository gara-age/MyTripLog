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

    @Namespace var animation

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                
                let columns = Array(repeating: GridItem(spacing:1), count: 1)

                LazyVGrid(columns: columns, spacing: 1, content: {
                    
                    ForEach(Array(tags.enumerated()), id: \.element.id) { index, tag in
                        GeometryReader {
                            let size = $0.size
                            
                            RowView(tag: tag, index: index)
                                .frame(width: 150, alignment: .center)

                                .draggable(tag.text) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial) //꺼도될듯
                                        .frame(width: 1, height: 1)
                                        .onAppear {
                                            draggedTag = tag
                                        }
                                }
                                .dropDestination(for: String.self) { items, location in
                                    draggedTag = nil
                                    return false
                                } isTargeted: { status in
                                    if let draggedTag, status, draggedTag != tag {
                                       if let sourceIndex = tags.firstIndex(of: draggedTag),
                                          let destinationIndex = tags.firstIndex(of: tag) {
                                           withAnimation(.bouncy){
                                               let sourceItem = tags.remove(at: sourceIndex)
                                               tags.insert(sourceItem, at: destinationIndex)
                                           }
                                       }
                                    }
                                }

                        }
                        .frame(height: fontSize + 20)

                            .onDrag {
                                NSItemProvider(object: tag.text as NSString)
                            }
                            .onDrop(of: ["public.text"], delegate: DragDropDelegate(tags: $tags, draggedTag: tags[index], draggedIndex: index))
                    }
                })
                .frame(width: 150, alignment: .center)
            }
            .scrollDisabled(true)
            .frame(maxWidth: .infinity)
        }
        .animation(.easeInOut, value: tags)
    }

    @ViewBuilder
    func RowView(tag: Tag, index: Int) -> some View {
        Text(tag.text)
            .font(.system(size: fontSize))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color("Tag"))
                    .frame(width: 150)
            )
            .foregroundColor(Color("BG"))
            .lineLimit(nil)
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .contextMenu {
                Button("Delete") {
                    tags.remove(at: index)
                }
            }
            .matchedGeometryEffect(id: tag.id, in: animation)
    }

    struct DragDropDelegate: DropDelegate {
        @Binding var tags: [Tag]
        var draggedTag: Tag
        var draggedIndex: Int

        func performDrop(info: DropInfo) -> Bool {
            guard let itemProvider = info.itemProviders(for: ["public.text"]).first else { return false }

            itemProvider.loadObject(ofClass: String.self) { (text, error) in
                if let text = text as? String {
                    let droppedTag = Tag(text: text, size: 16)

                    // Insert the dragged tag at the new location
                    DispatchQueue.main.async {
                        tags.insert(droppedTag, at: draggedIndex)
                        
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



#Preview {
    ContentView()
}
