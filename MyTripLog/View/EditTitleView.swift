//
//  EditTitleView.swift
//  MyTripLog
//
//  Created by 최민서 on 2/23/24.
//

import SwiftUI
import SwiftData

struct EditTitleView: View {
    
   @Binding var selectedTrip : Travel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(animation: .snappy) private var allTravels: [Travel]
    @Query(animation: .snappy) private var allTags: [Tag]

    @State private var oldTitle : String = ""
    
    @State private var newTitle : String = ""
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField(selectedTrip.title, text: $newTitle)
                }
            }
            .navigationTitle("여정명 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        saveChanges()
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allTravels.contains(where: { $0.title == newTitle }))

                    .tint(.blue)
                }

            }
        }
        .onAppear{
            self.oldTitle = selectedTrip.title
        }
            .presentationDetents([.height(180)])

        .interactiveDismissDisabled()

    }
    private func saveChanges() {
            selectedTrip.title = newTitle
            try? context.save()
            
            // 선택한 여정의 이전 제목으로 태그를 찾아 새 제목으로 업데이트
            let tagsToUpdate = allTags.filter { $0.travelTitle == oldTitle }
            for tag in tagsToUpdate {
                tag.travelTitle = newTitle
            }
            
            // 변경된 태그 저장
            try? context.save()
            
            dismiss()
        }
}
