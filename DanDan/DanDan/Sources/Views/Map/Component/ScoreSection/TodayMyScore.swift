//
//  TodayMyScore.swift
//  DanDan
//
//  Created by soyeonsoo on 11/4/25.
//

import SwiftUI

struct TodayMyScore: View {
    var score: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("오늘 내 점수")
                .font(.PR.caption5)
                .foregroundStyle(.gray1)
                .padding(.top, 4)
            
            Text("\(score)")
                .font(.PR.title2)
                .foregroundStyle(.steelBlack)
        }
        .frame(width: 86, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
        )
    }
}

#Preview {
    TodayMyScore(score: 3)
}
