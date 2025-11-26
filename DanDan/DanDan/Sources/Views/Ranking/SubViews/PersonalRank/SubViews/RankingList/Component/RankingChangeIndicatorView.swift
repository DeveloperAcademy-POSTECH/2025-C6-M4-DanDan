//
//  RankingChangeIndicatorView.swift
//  DanDan
//
//  Created by Jay on 11/4/25.
//

import SwiftUI

struct RankingChangeIndicatorView: View {
    let rankDiff: Int
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Image(rankDiff >= 0 ? "rank_up" : "rank_down")
                .resizable()
                .frame(width: 6, height: 6)
                .offset(y: rankDiff > 0 ? -2 : 0)
            
            Text("\(abs(rankDiff))")
                .font(.pretendard(.bold, size: 12))
                .foregroundStyle(.gray1)
        }
    }
}
