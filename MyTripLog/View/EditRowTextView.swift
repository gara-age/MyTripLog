//
//  EditRowTextView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/21/24.
//

import SwiftUI

struct EditRowTextView: View {
    @Binding var editedText : String
    @Binding var tags: [Tag]

    var onSubmit : () -> ()
    var onClose : () -> ()
 
    
    var body: some View {
        VStack{
            TextField("apple", text: $editedText)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color("Tag").opacity(0.2), lineWidth: 1))
            HStack(spacing: 15){
                Button("취소") {
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.red)
                
                Button("수정") {
                    onSubmit()
                    
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.blue)
                .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || tags.contains(where: { $0.text == editedText }))

            }
            .padding(.top, 10)
        }
        .padding(15)
        .background(.bar, in: .rect(cornerRadius : 10))
        .padding(.horizontal, 30)
    }
}

