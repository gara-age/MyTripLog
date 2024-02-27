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
                        selectedTrip.title = newTitle
                        try? context.save()
                            dismiss()
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || allTravels.contains(where: { $0.title == newTitle }))

                    .tint(.blue)
                }

            }
        }
     
            .presentationDetents([.height(180)])

        .interactiveDismissDisabled()

    }
}
