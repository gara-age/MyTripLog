//
//  TagView.swift
//  TaggingApp
//
//  Created by 최민서 on 1/8/24.
//

import SwiftUI
import SwiftData

// Custom View
struct TagView: View {
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allTags: [Tag]
    @Query(animation: .snappy) private var allTravel: [Travel]

    @Binding var tags : [Tag]
    var title: String = "Add Some Tags"
    var fontSize: CGFloat = 16
    @Binding var draggedTag: Tag?
    @Binding var tagText : String
    //Adding Geometry Effect to Tag
    @Namespace var animation
    @Binding var tagView : Bool
    @Binding var editMode: Bool
    @State private var editedText: String = ""
    @Binding var originalText: String
    @Binding var getTagColor : Color
    @Binding var dropDone : Bool
    @Binding var escape : Bool
    @State private var deleteRequest : Bool = false
    @State private var tagToDelete: Tag?
    @State private var cancelExecute: DispatchWorkItem?
    let cancelFunction: () -> Void
    let cancelByWaitFunction: () -> Void
    @State private var travel: Travel?
    @Binding var nameText : String
    @State private var dayIndex = 100
    @Binding var moveToATV : Bool
    @State private var stopFetching = false

    var updateTags: ((Tag, String) -> Void)?
    
    
    var body: some View {
        //ScrollView
        VStack(alignment: .leading,spacing: 15){
            
            
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .leading, spacing: 10){
                    //Displaying Tags
                    ForEach(getRows(), id: \.self){ rows in
                        
                        HStack(spacing: 6){
                            ForEach(rows) { row in
                                
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
            .onAppear{
                if !moveToATV {
                   if tags.isEmpty {
                        loadTags()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
        }
//        .animation(.easeInOut, value: tags) //필요에 따라 꺼도될듯
    }
    //MARK: - RowView
    
    @ViewBuilder
    func RowView(tag: Tag)->some View{
        Text(tag.text)
            .font(.system(size: fontSize))
            .padding(.horizontal, 14)
            .padding(.vertical,8)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: tag.color))
            )
            .foregroundColor(Color(hex: tag.fontColor))
            .lineLimit(1)
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .contextMenu{
                Button("내용 수정") {
                    DispatchQueue.main.async {
                        tagText = tag.text
                        originalText = tag.text
                    }
                    updateTags?(tag, editedText)
                    
                }
                Button("색상 변경") {
                    DispatchQueue.main.async {
                        originalText = tag.text
                        tagText = tag.text
                    }
                    
                    UIColorWellHelper.helper.execute?()
                }
                Button("삭제"){
                    DispatchQueue.main.async {
                        tagText = tag.text
                        tagToDelete = tag
                    }
                    deleteRequest.toggle()
                    
                }
            }
            .if(!escape){
                $0
                    .draggable(tag.text) {
                        
                        Text(tag.text)
                            .font(.system(size: fontSize))
                            .padding(.horizontal, 14)
                            .padding(.vertical,8)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(hex: tag.color))
                            )
                            .foregroundColor(Color("BGColor"))
                            .contentShape(RoundedRectangle(cornerRadius: 5))
                        
                            .onAppear{
                                tagView = true
                                dropDone = false
                                escape = false
                                getTagColor = Color(hex:tag.color)
                                
                                draggedTag = tag
                                cancelFunction()
                                cancelByWaitFunction()
                                
                            }
                        
                    }
            }
            .alert("일정 삭제시 동일한 이름의 일정이 모두 삭제됩니다. 정말 삭제하시겠습니까?", isPresented: $deleteRequest) {
                Button(role: .destructive) {
                    if let tagToDelete = tagToDelete, let tagIndex = tags.firstIndex(of: tagToDelete) {
                        removeTag(withText: tagToDelete.text, from: &tags)
                        // 해당 Tag를 DaysTagView에서도 삭제하기 위해 Notification을 보냅니다.
                        NotificationCenter.default.post(name: Notification.Name("TagDeleted"), object: tagToDelete)
                    }
                } label: {
                    Text("삭제")
                }
                
                Button(role: .cancel) {
                    deleteRequest = false
                } label: {
                    Text("취소")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TagColorChanged"))) { notification in
                if let userInfo = notification.object as? [String: Any],
                   let color = userInfo["color"] as? Color,
                   let originalText = userInfo["originalText"] as? String {
                    let hexColor = color.toHex()

                    // Find and update the tag in tags based on text
                    if let index = tags.firstIndex(where: { $0.text == originalText }) {
                        tags[index].color = hexColor
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("saveTag"))) { notification in
                if let userInfo = notification.object as? [String: Any],
                   let travelTitle = userInfo["TravelTitle"] as? String {

                    let existingTags = allTags.filter { $0.travelTitle == travelTitle && $0.dayIndex == 100 }

                    let tagExists = existingTags.contains { existingTag in
                        existingTag.id == tag.id && existingTag.text == tag.text
                    }

                    if !tagExists {
                        if let foundTravel = allTravel.first(where: { $0.title == nameText }) {
                            travel = foundTravel
                        }

                        let savedTag = Tag(id: tag.id, text: tag.text, size: tag.size, color: tag.color, height: tag.height, fontColor: tag.fontColor, travel: travel, travelTitle: travelTitle, dayIndex: 100, rowIndex: 100)

                        DispatchQueue.main.async {
                            context.insert(savedTag)
                            print("\(savedTag.text) tags")

                            try! context.save()
                        }
                    }
                }
            }

           
    }
    func loadTags() {
        let tagsPredicate = #Predicate<Tag> {
            $0.travelTitle == nameText && $0.dayIndex == 100
        }

        let descriptor = FetchDescriptor<Tag>(predicate: tagsPredicate)

        do {
            let trips = try context.fetch(descriptor)

            DispatchQueue.main.async {
                guard tags.isEmpty else { return }

                tags = trips


            }
        } catch {
            print("fuck! cannot load tags")
        }
    }
    private func deleteTag(tag: Tag) {
        tags.removeAll { $0.text == tag.text }
        // 해당 Tag를 DaysTagView에서도 삭제하기 위해 Notification을 보냅니다.
        NotificationCenter.default.post(name: Notification.Name("TagDeleted"), object: tag)
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
            totalWidth += ((tag.size ?? 0) + 30) // Capsule일때는 40, roundedRectangle일떄는 30
            
            //checking if totalwidth is greater than size
            if totalWidth > screenWidth{
                //adding row in rows
                //clearing the data
                //checking for long string
                totalWidth = (!currentRow.isEmpty || rows.isEmpty ? ((tag.size ?? 0) + 40) : 0 )
                
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
    
    let color = Color(hue: Double(text.hashValue % 100) / 100.0, saturation: 0.5, brightness: 0.9)
    let hexBG = color.toHex()

    let height : CGFloat = 36
    
    var fontColor : Color = Color.BG
    let hexFG = fontColor.toHex()

    
    return Tag(text: text, size: size.width, color: hexBG, height: height, fontColor: hexFG)
}

func getSize(tags: [Tag])->Int{
    var count: Int = 0
    
    tags.forEach { tag in
        count += Int(tag.size ?? 0)
    }
    return count
}
func removeTag(withText text: String, from tags: inout [Tag]) {
    tags.removeAll { $0.text == text }
}
extension Color {
    func toHex() -> String {
           guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
               return ""
           }
           
           let red = Int(components[0] * 255.0 + 0.5)
           let green = Int(components[1] * 255.0 + 0.5)
           let blue = Int(components[2] * 255.0 + 0.5)
           
           return String(format: "#%02X%02X%02X", red, green, blue)
       }
    init(hex: String) {
           var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
           hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

           var rgb: UInt64 = 0
           Scanner(string: hexSanitized).scanHexInt64(&rgb)

           let red = Double((rgb & 0xFF0000) >> 16) / 255.0
           let green = Double((rgb & 0x00FF00) >> 8) / 255.0
           let blue = Double(rgb & 0x0000FF) / 255.0

           self.init(red: red, green: green, blue: blue)
       }
}
