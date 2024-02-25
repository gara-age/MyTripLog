//
//  EditTitleView.swift
//  MyTripLog
//
//  Created by 최민서 on 2/23/24.
//

import SwiftUI

struct EditTitleView: View {
    @Bindable var travel : Travel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context


    @State private var newTitle : String = ""
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField(travel.title, text: $newTitle)
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
                        travel.title = newTitle
                        try? context.save()
                            dismiss()
                    }
                    .disabled(newTitle.isEmpty)
                    .tint(.blue)
                }
            }
        }
     
            .presentationDetents([.height(180)])

        .interactiveDismissDisabled()

    }
}
