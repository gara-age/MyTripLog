//
//  MainView.swift
//  MyTripLog
//
//  Created by 최민서 on 1/6/24.
//

import SwiftUI

struct MainView: View {
    @State private var add : Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                RoundedRectangle(cornerRadius: 10)
                    .frame( width: 350, height: 150)
                    .foregroundColor(Color.purple)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .alignmentGuide(HorizontalAlignment.trailing, computeValue: { d in
                                d[.trailing]
                            })
                            .alignmentGuide(VerticalAlignment.top, computeValue: { d in
                                d[.top]
                            })
                            .offset(x: 150, y: -40)
                            .font(.largeTitle)
                    )
                RoundedRectangle(cornerRadius: 10)
                    .frame( width: 350, height: 150)
                    .foregroundColor(Color.blue)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .alignmentGuide(HorizontalAlignment.trailing, computeValue: { d in
                                d[.trailing]
                            })
                            .alignmentGuide(VerticalAlignment.top, computeValue: { d in
                                d[.top]
                            })
                            .offset(x: 150, y: -40)
                            .font(.largeTitle)
                        
                    )
                RoundedRectangle(cornerRadius: 10)
                    .frame( width: 350, height: 150)
                    .foregroundColor(Color.orange)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .alignmentGuide(HorizontalAlignment.trailing, computeValue: { d in
                                d[.trailing]
                            })
                            .alignmentGuide(VerticalAlignment.top, computeValue: { d in
                                d[.top]
                            })
                            .offset(x: 150, y: -40)
                            .font(.largeTitle)
                        
                    )
            }
            .navigationTitle("모든 일정")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        add.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $add, content: {
                SetdetailVIew()
            })
        }
    }
}

#Preview {
    MainView()
}
