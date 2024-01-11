//
//  DaysTagView.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI

// Custom View
struct DaysTagView: View {
    @Binding var tags : [Tag]
    @State private var draggedTag: Tag?
      @State private var dragOffset: CGSize = .zero
    var title: String = "Add Some Tags"
    var fontSize: CGFloat = 16
    
    //Adding Geometry Effect to Tag
    @Namespace var animation
    
    var body: some View {
//ScrollView
        VStack{

            
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(spacing: 1){

                    ForEach(tags, id: \.self) { tag in
                                       // Row View
                                       RowView(tag: tag)
                                   }
                }
                .frame(width: 150)

                
            }
            .frame(maxWidth: .infinity)
 
        }

        .animation(.easeInOut, value: tags) //필요에 따라 꺼도될듯
    }
    
    @ViewBuilder
    func RowView(tag: Tag)->some View{
        Text(tag.text)
            .font(.system(size: fontSize))
        //adding capsule
            .padding(.horizontal, 14)
            .padding(.vertical,8)
            .background(
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color("Tag"))
                .frame(width: 150)
            )
            .foregroundColor(Color("BG"))
            .lineLimit(1)
        // Delete
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .contextMenu{
                Button("Delete"){
                    //deleting
                    tags.remove(at: getIndex(tag: tag))
                }
            }
            .onDrag {
                           NSItemProvider(object: tag.text as NSString)
                       }
            .matchedGeometryEffect(id: tag.id, in: animation)
    }
    
    func getIndex(tag: Tag) ->Int{
        let index = tags.firstIndex{ currentTag in
            return tag.id == currentTag.id
        } ?? 0
        
        return index
    }
    

}

#Preview {
    ContentView()
}
