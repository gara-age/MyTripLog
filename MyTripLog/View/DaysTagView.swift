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
                
                VStack{

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
    
    //Basic Logic
    //Splitting the array when it exceeds the scrren size
    func getRows()->[[Tag]]{
        
        var rows: [[Tag]] = []
        var currentRow: [Tag] = []
        
        var totalWidth: CGFloat = 0
    //For safety extra 10
        let screenWidth: CGFloat = UIScreen.main.bounds.width - 90
        
        tags.forEach { tag in
            
            // updating total width
            
            //adding the capsule size into total width with spacing
            //14 + 14 + 6 + 6
            //extra 6 for safe
            totalWidth += (tag.size + 30) // Capsule일때는 40, roundedRectangle일떄는 30
            
            //checking if totalwidth is greater than size
            if totalWidth > screenWidth{
                //adding row in rows
                //clearing the data
                //checking for long string
                totalWidth = (!currentRow.isEmpty || rows.isEmpty ? (tag.size + 40) : 0 )
                
                rows.append(currentRow)
                currentRow.removeAll()
                currentRow.append(tag)
            } else {
                currentRow.append(tag)
            }
        }
        
        //safe check
        //if having any value storing in rows
        if !currentRow.isEmpty{
            rows.append(currentRow)
            currentRow.removeAll()
        }
        
        return rows
    }
}

#Preview {
    ContentView()
}
