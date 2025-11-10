//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct TeamRankingListView: View {
    let teamRankings: [TeamRanking]
    let myUserId: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(teamRankings) { item in
                    TeamRankingItemView(
                        teamRankings: item,
                        isMyRank: item.id == myUserId
                    )
                }
            }
        }
    }
}
