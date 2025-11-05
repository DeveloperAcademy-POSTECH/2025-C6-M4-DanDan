//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct RankingListView: View {
    let rankingItems: [RankingViewModel.RankingItemData]
    let myUserId: UUID

    private var topThreeItems: [RankingViewModel.RankingItemData] {
        Array(rankingItems.sorted { $0.ranking < $1.ranking }.prefix(3))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if !topThreeItems.isEmpty {
                    RankingCardSectionView(
                        rankingItems: topThreeItems,
                        myUserId: myUserId
                    )
                    .padding(.vertical, 36)
                }

                ForEach(rankingItems) { item in
                    RankingItemView(
                        rank: item,
                        isMyRank: item.id == myUserId
                    )
                }
            }
        }
    }
}

#Preview {
    RankingListView(
        rankingItems: [
            .init(
                id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                ranking: 1,
                userName: "소연수",
                userImage: nil,
                userWeekScore: 12,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            ),
            .init(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                ranking: 2,
                userName: "김소원",
                userImage: nil,
                userWeekScore: 9,
                userTeam: "blue",
                backgroundColor: .blue.opacity(0.1)
            ),
            .init(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
                ranking: 3,
                userName: "허찬욱",
                userImage: nil,
                userWeekScore: 7,
                userTeam: "yellow",
                backgroundColor: .yellow.opacity(0.1)
            ),
        ],
        myUserId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
    )
}
