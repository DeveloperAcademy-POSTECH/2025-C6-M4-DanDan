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
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(rankDiff > 0 ? "rank_up" : "rank_down")
                .resizable()
                .frame(width: 8, height: 8)
                .offset(y: rankDiff > 0 ? -4 : 0)
            
            Text("\(abs(rankDiff))")
                .font(.PR.body1)
                .foregroundStyle(.gray1)
        }
    }
}

#Preview {
    RankingChangeIndicatorView(rankDiff: 4)
    RankingChangeIndicatorView(rankDiff: -4)
}
