//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//


import SwiftUI

struct RankingListView: View {
    let rankingItems: [RankingViewModel.RankingItemData]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(rankingItems) { item in
                    RankingItemView(rank: item)
                }
            }
            .padding(.top, 16)
        }
    }
}

#Preview {
    RankingListView(rankingItems: [
        .init(ranking: 1, userName: "소연수", userImage: nil, userWeekScore: 12, userTeam: "blue", backgroundColor: .blue.opacity(0.1)),
        .init(ranking: 2, userName: "김소원", userImage: nil, userWeekScore: 9, userTeam: "blue", backgroundColor: .blue.opacity(0.1)),
        .init(ranking: 3, userName: "허찬욱", userImage: nil, userWeekScore: 7, userTeam: "yellow", backgroundColor: .yellow.opacity(0.1))
    ])
}
