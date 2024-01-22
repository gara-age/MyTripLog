//
//  TagView.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI

// Custom View
struct TagView: View {
    @Binding var tags : [Tag]
    @State private var draggedTag: Tag?
      @State private var dragOffset: CGSize = .zero
    var title: String = "Add Some Tags"
    var fontSize: CGFloat = 16

    //Adding Geometry Effect to Tag
    @Namespace var animation
    @Binding var tagView : Bool
    @Binding var editMode: Bool
     @State private var editedText: String = ""
    
    var body: some View {
//ScrollView
        VStack(alignment: .leading,spacing: 15){

            
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .leading, spacing: 10){
                    //Displaying Tags
                    ForEach(getRows(), id: \.self){ rows in
                     
                        HStack(spacing: 6){
                            ForEach(rows){ row in
                                
                                //Row View
                                RowView(tag: row)
                              
                                
                                
                                
                            }
                        }
                    }
                    
                }
                .frame(width: UIScreen.main.bounds.width - 80, alignment: .leading)
                .padding(.vertical)
                .padding(.bottom, 20)
                
            }
            .frame(maxWidth: .infinity)
 
        }

        .animation(.easeInOut, value: tags) //필요에 따라 꺼도될듯
    }
    
    @ViewBuilder
    func RowView(tag: Tag)->some View{
        Text(tag.text)
            .font(.system(size: fontSize))
            .padding(.horizontal, 14)
            .padding(.vertical,8)
            .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(tag.color)
            )
            .foregroundColor(Color("BG"))
            .lineLimit(1)
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .contextMenu{
                Button("내용 수정") {
                    editMode = true
                }
                Button("색상 변경") {
                 print("색상 변경")
                }
                Button("삭제"){

                    tags.remove(at: getIndex(tag: tag))
                        //.alert로 "해당 내역을 모든 일정에서 삭제하시겠습니까?"
                }
            }
            .onDrag {
                tagView = true
                print(tagView)
                return NSItemProvider(object: tag.text as NSString)

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

//Global function
func addTag(text: String, fontSize: CGFloat)->Tag{
    //getting text size
    let font = UIFont.systemFont(ofSize: fontSize)
    
    let attributes = [NSAttributedString.Key.font: font]
    
    let size = (text as NSString).size(withAttributes: attributes)

    let color = Color(hue: Double(text.hashValue % 100) / 100.0, saturation: 0.8, brightness: 0.8)

    return Tag(text: text, size: size.width, color: color)
}

func getSize(tags: [Tag])->Int{
    var count: Int = 0
    
    tags.forEach { tag in
        count += Int(tag.size)
    }
    return count
}
