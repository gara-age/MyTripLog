//
//  ChoosePictureView.swift
//  MyTripLog
//
//  Created by 최민서 on 2/22/24.
//

import SwiftUI

struct ChoosePictureView: View {
    @Environment(\.dismiss) private var dismiss
    @State
    var onClose : () -> ()
    var onSelectImage : (String) -> ()
    
    @State var backGroundImage : [String] = ["USA" , "Japan", "Canada", "China", "Dubai", "Hawaii", "Korea", "Mountain",]
    var body: some View {
          ScrollView(.horizontal, showsIndicators: false) {
              VStack{
                  LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 3,
                    content: {
                        ForEach(backGroundImage, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .padding(.top)
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .onTapGesture {
                                    onSelectImage(imageName)
                                }
                        }
                    }
                  )
                  Button{
                      onClose()
                  } label: {
                      Text("돌아가기")
                          .foregroundStyle(.BG)
                          .background(
                          RoundedRectangle(cornerRadius: 5)
                            .frame(width: 90, height: 30))
                          .padding(.all)
                  }
              }
          }
          .padding()
          .frame(maxHeight: .infinity)
      }
}

