//
//  TagReSizingVIew.swift
//  MyTripLog
//
//  Created by 최민서 on 1/28/24.
//

import SwiftUI

struct TagReSizingVIew: View {
    @Binding var tagText : String
    @Binding var tagColor : Color
    
    @State private var heightSize : CGFloat = 36
    @State private var text = "Test Text"
    @State private var fontSize : CGFloat = 16
    @Binding var tagTime : CGFloat
    @Binding var tagHeight : CGFloat
    @Binding var tagID : String
    @State private var setTagTime = 1.0
    @Binding var changeAll : Bool
    @State private var isTagFull : Bool = false


    var onSubmit : () -> ()
    var onClose : () -> ()
    
    init(tagText: Binding<String>, tagColor: Binding<Color>, tagTime: Binding<CGFloat>, tagHeight: Binding<CGFloat>,tagID: Binding<String>,changeAll: Binding<Bool>, onSubmit: @escaping () -> (), onClose: @escaping () -> ()) {
        self._tagText = tagText
        self._tagColor = tagColor
        self._tagTime = tagTime
        self._tagHeight = tagHeight
        self._tagID = tagID
        self._changeAll = changeAll
        self.onSubmit = onSubmit
        self.onClose = onClose
        self._setTagTime = State(initialValue: tagHeight.wrappedValue / 36)
        self._heightSize = State(initialValue: tagHeight.wrappedValue)
    }
    var formattedTime: String {
        let hours = Int(setTagTime)
        let minutes = Int((setTagTime - Double(hours)) * 60)
        
        if minutes == 0 {
            return "현재 시간: \(hours)시간"
        } else {
            return "현재 시간: \(hours)시간 \(minutes)분"
        }
    }
    func incrementTagTime() {
        setTagTime += 0.5
        heightSize = CGFloat(setTagTime * 36)
        tagTime = setTagTime
    }
    func decrementTagTime() {
        guard setTagTime > 0.5 else { return }
        setTagTime -= 0.5
        heightSize = CGFloat(setTagTime * 36)
        tagTime = setTagTime
    }
    var body: some View {
        VStack(spacing: 10){
            Spacer()
            Spacer()
            
            Text(tagText)
                .font(.system(size: fontSize))
                .padding(.horizontal, 14)
                .padding(.vertical,8)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(tagColor)
                        .frame(width: 150)
                        .frame(height: heightSize )
                )
                .foregroundColor(Color.BG)
                .lineLimit(1)
                .contentShape(RoundedRectangle(cornerRadius: 5))
            Spacer()
            Spacer()
            
            Text(formattedTime)
            HStack(spacing: 50){
                Button(" - 30분 ") {
                    decrementTagTime()
                    
                }
                .tint(.minus)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .disabled(heightSize == 18 || setTagTime == 0.5)
                
                Button(" +30 분 ") {
                    incrementTagTime()
                    
                }
                .disabled(isTagFull)
                .tint(.plus)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
            }
            Spacer()
            Text("일정이 모두 차버려 더 이상 시간을 추가할 수 없습니다.")
                .opacity(isTagFull ? 1 : 0)
            Toggle("동일한 일정들의 시간 모두 변경", isOn: $changeAll)
                .toggleStyle(SwitchToggleStyle(tint: .black))
            Spacer()
            
            HStack(spacing: 50){
                
                
                Button("취소") {
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.red)
                
                Button("수정") {
                    onSubmit()
                    //일정 꽉 찰 경우 + 눌렀을때 비활성화 처리
                  
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 5))
                .tint(.blue)
                
            }
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        
    }
    
}
