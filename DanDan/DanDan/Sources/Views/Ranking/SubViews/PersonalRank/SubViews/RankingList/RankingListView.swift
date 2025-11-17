//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct RankingListView: View {
    let rankingItems: [RankingItemData]
    let myUserId: UUID
    let rankDiff: Int

    private var sortedItems: [RankingItemData] {
        rankingItems.sorted { $0.ranking < $1.ranking }
    }

    private var topThreeItems: [RankingItemData] {
        Array(sortedItems.prefix(3))
    }

    private var remainingItems: [RankingItemData] {
        Array(sortedItems.dropFirst(3))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !topThreeItems.isEmpty {
                    RankingCardSectionView(
                        rankingItems: topThreeItems,
                        myUserId: myUserId
                    )
                    .padding(.vertical, 36)
                }

                ForEach(Array(remainingItems.enumerated()), id: \.element.id) {
                    index,
                    item in
                    RankingItemView(
                        rank: item,
                        isMyRank: item.id == myUserId,
                        displayRank: index + 4,  // 상위 3개 이후라 +4 (index는 0부터 시작)
                        rankDiff: rankDiff
                    )
                }
            }
        }
    }
}
