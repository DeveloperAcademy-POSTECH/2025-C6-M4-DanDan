//
//  PersonalRankView.swift
//  DanDan
//
//  Created by Jay on 11/2/25.
//

import SwiftUI

struct PersonalRankView: View {
    let rankingItems: [RankingItemData]
    let myUserId: UUID
    let rankingFilter: (
            [RankingItemData],
            String,
            UUID
    ) -> [RankingItemData]
    let fetchRanking: () -> Void
    let myRankDiff: Int

    @State private var selectedFilter: String = "전체"
    
    private var filteredItems: [RankingItemData] {
        rankingFilter(rankingItems, selectedFilter, myUserId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            InstructionSectionView(selectedFilter: $selectedFilter)
                .padding(.top, 45)

            RankingListView(
                rankingItems: filteredItems,
                myUserId: myUserId,
                myRankDiff: myRankDiff
            )
        }
        .padding(.horizontal, 20)
        .onAppear() {
            fetchRanking()
        }
    }
}
