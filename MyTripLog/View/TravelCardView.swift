//
//  TravelCardView.swift
//  MyTripLog
//
//  Created by 최민서 on 2/19/24.
//

import SwiftUI
import SwiftData

struct TravelCardView: View {
    @Environment(\.modelContext) private var context
    @Binding var editTitle : Bool
     var trip : Travel
    
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy.MM.dd"
           return formatter
       }()
    
    var body: some View {
                HStack{
                    VStack(alignment: .leading){
                        Text(trip.title)
                            .padding(.vertical)
                        Text("\(dateFormatter.string(from:trip.startDate)) ~ \(dateFormatter.string(from: trip.endDate))")
                        Spacer()
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(.trailing, 80)
                }
                
                
                .background(     RoundedRectangle(cornerRadius: 20)
                    .overlay(Image(trip.imageString)
                        .resizable()
                        .scaledToFill()
                        .colorMultiply(.gray))
                        .frame( width: 350, height: 150)
                                 /*.foregroundColor(Color.tag)*/)
                .frame(width: 350, height: 150)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
             
            }
                  
    
}

