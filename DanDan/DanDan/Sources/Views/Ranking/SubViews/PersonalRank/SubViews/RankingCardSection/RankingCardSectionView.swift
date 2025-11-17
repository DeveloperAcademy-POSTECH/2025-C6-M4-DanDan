//
//  RankingCardSectionv.swift
//  DanDan
//
//  Created by Jay on 11/5/25.
//

import SwiftUI

struct RankingCardSectionView: View {
    let rankingItems: [RankingViewModel.RankingItemData]
    let myUserId: UUID

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            let topThree = Array(
                rankingItems.sorted { $0.ranking < $1.ranking }.prefix(3)
            )

            RankingCard(
                userId: topThree[1].id,
                myUserId: myUserId,
                name: topThree[1].userName,
                score: topThree[1].userWeekScore,
                image: Image(uiImage: topThree[1].userImage ?? (UIImage(named: "default_avatar") ?? UIImage())),
                userTeam: topThree[1].userTeam,
                rank: 2
            )
            
            RankingCard(
                userId: topThree[0].id,
                myUserId: myUserId,
                name: topThree[0].userName,
                score: topThree[0].userWeekScore,
                image: Image(uiImage: topThree[0].userImage ?? (UIImage(named: "default_avatar") ?? UIImage())),
                userTeam: topThree[0].userTeam,
                rank: 1
            )
            .padding(.bottom, 20)
            
            RankingCard(
                userId: topThree[2].id,
                myUserId: myUserId,
                name: topThree[2].userName,
                score: topThree[2].userWeekScore,
                image: Image(uiImage: topThree[2].userImage ?? (UIImage(named: "default_avatar") ?? UIImage())),
                userTeam: topThree[2].userTeam,
                rank: 3
            )
        }
    }
}
