//
//  TravelCardView.swift
//  MyTripLog
//
//  Created by 최민서 on 2/19/24.
//

import SwiftUI

struct TravelCardView: View {
    var body: some View {
        HStack{
            VStack{
                Text("오사카 3박 4일 여행")
                    .padding(.top)
                Text("2024.04.10 ~ 2024.04.13")
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.trailing, 80)
        }
        
        .background(     RoundedRectangle(cornerRadius: 10)
            .frame( width: 350, height: 150)
            .foregroundColor(Color.tag))
        .frame(width: 350, height: 150)
        .frame(maxWidth: .infinity, maxHeight: .infinity , alignment: .topLeading)
        .overlay(
            Group {
                Menu(content: {
                    Button {
                        
                    } label: {
                        Text("PDF로 내보내기")
                    }
                    Button {
                        
                    } label: {
                        Text("이미지로 내보내기")
                    }
                    Button {
                        
                    } label: {
                        Text("지우기")
                    }
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.white)
                        .rotationEffect(.degrees(90))
                        .alignmentGuide(HorizontalAlignment.trailing, computeValue: { d in
                            d[.trailing]
                        })
                        .alignmentGuide(VerticalAlignment.top, computeValue: { d in
                            d[.top]
                        })
                        .frame(width: 30, height: 30, alignment: .topTrailing)
                })
                .offset(x: 150, y: -30)
                
                .font(.largeTitle)
                .contentShape(Rectangle().size(width: 100, height: 100))
                .padding(.horizontal, 10)
            }
        )
    }
}

#Preview {
    TravelCardView()
}
