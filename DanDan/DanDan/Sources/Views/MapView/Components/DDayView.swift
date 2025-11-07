//
//  DDayView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/3/25.
//

import SwiftUI

struct DDayView: View {
    let dday: Int
    
    private var ddayText: String {
        dday == 0 ? "D-Day" : "D-\(dday)"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("경기 종료까지")
                .font(.PR.body4)
                .foregroundStyle(.gray1)
            
            Text(ddayText)
                .font(.PR.title2)
                .foregroundStyle(.steelBlack)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
        )
        .fixedSize()
    }
}

//
//#Preview {
//    let start = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
//    let period = ConquestPeriod(startDate: start, durationInDays: 7)
//        
//    DDayView(period: period)
//        .padding(.top, 8)
//        .padding(.leading, 20)
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//    
//}
