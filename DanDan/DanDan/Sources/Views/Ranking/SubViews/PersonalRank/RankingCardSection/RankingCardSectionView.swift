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
        HStack(spacing: 12) {
            let topThree = Array(
                rankingItems.sorted { $0.ranking < $1.ranking }.prefix(3)
            )

            RankingCard(
                userId: topThree[1].id,
                myUserId: myUserId,
                name: topThree[1].userName,
                score: topThree[1].userWeekScore,
                image: Image(uiImage: topThree[1].userImage ?? (UIImage(named: "testImage") ?? UIImage())),
                color: topThree[1].backgroundColor,
                rank: 2
            )
            

            RankingCard(
                userId: topThree[0].id,
                myUserId: myUserId,
                name: topThree[0].userName,
                score: topThree[0].userWeekScore,
                image: Image(uiImage: topThree[0].userImage ?? (UIImage(named: "testImage") ?? UIImage())),
                color: topThree[0].backgroundColor,
                rank: 1
            )
            .padding(.bottom, 20)

            RankingCard(
                userId: topThree[2].id,
                myUserId: myUserId,
                name: topThree[2].userName,
                score: topThree[2].userWeekScore,
                image: Image(uiImage: topThree[2].userImage ?? (UIImage(named: "testImage") ?? UIImage())),
                color: topThree[2].backgroundColor,
                rank: 3
            )
        }
    }
}

#Preview {
    RankingCardSectionView(
        rankingItems: [
            .init(
                id: UUID(),
                ranking: 1,
                userName: "소연수",
                userImage: nil,
                userWeekScore: 12,
                userTeam: "blue",
                backgroundColor: .subA20
            ),
            .init(
                id: UUID(),
                ranking: 2,
                userName: "김소원",
                userImage: nil,
                userWeekScore: 9,
                userTeam: "blue",
                backgroundColor: .subA20
            ),
            .init(
                id: UUID(),
                ranking: 3,
                userName: "허찬욱",
                userImage: nil,
                userWeekScore: 7,
                userTeam: "yellow",
                backgroundColor: .subB20
            ),
        ],
        myUserId: UUID()
    )
}
