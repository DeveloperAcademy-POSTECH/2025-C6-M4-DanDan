//
//  RankingListView.swift
//  DanDan
//
//  Created by Jay on 11/3/25.
//

import SwiftUI

struct TeamRankingListView: View {
    let teamRankings: [TeamRanking]
    let userTeamName: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(teamRankings) { item in
                    TeamRankingItemView(
                        teamRankings: item,
                        isUserTeam: item.teamName == userTeamName
                    )
                }
            }
        }
    }
}
