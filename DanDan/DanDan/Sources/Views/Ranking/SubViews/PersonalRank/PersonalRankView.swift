//
//  PersonalRankView.swift
//  DanDan
//
//  Created by Jay on 11/2/25.
//

import SwiftUI

struct PersonalRankView: View {
    let rankingItems: [RankingViewModel.RankingItemData]

    var body: some View {
        VStack(spacing: 0) {
            InstructionSectionView()
                .padding(.top, 52)
                .padding(.bottom, 36)
            
            RankingListView(rankingItems: rankingItems)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PersonalRankView(
        rankingItems: [
            .init(
                ranking: 1,
                userName: "소연수",
                userImage: nil,
                userWeekScore: 12,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            ),
            .init(
                ranking: 2,
                userName: "김소원",
                userImage: nil,
                userWeekScore: 9,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            ),
            .init(
                ranking: 3,
                userName: "허찬욱",
                userImage: nil,
                userWeekScore: 7,
                userTeam: "yellow",
                backgroundColor: .yellow.opacity(0.1)
            ),
        ]
    )
}
