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
    let myTeamRankDiff: Int

    @State private var selectedFilter: String = "전체"
    
    private var filteredItems: [RankingItemData] {
        rankingFilter(rankingItems, selectedFilter, myUserId)
    }
    
    /// 선택한 필터에 따라 적절한 diff 전달
    private var currentRankDiff: Int {
        selectedFilter == "전체" ? myRankDiff : myTeamRankDiff
    }
    
    var body: some View {
        VStack(spacing: 0) {
            InstructionSectionView(selectedFilter: $selectedFilter)
                .padding(.top, 45)

            RankingListView(
                rankingItems: filteredItems,
                myUserId: myUserId,
                rankDiff: currentRankDiff,
            )
        }
        .padding(.horizontal, 20)
        .onAppear() {
            fetchRanking()
        }
    }
}
