//
//  TeamRankView.swift
//  DanDan
//
//  Created by Jay on 11/2/25.
//

import SwiftUI

struct TeamRankView: View {
    let fetchTeamRanking: () -> Void
    let fetchMyRanking: () -> Void
    let userTeamName: String
    let teamRankings: [TeamRanking]

    var body: some View {
        VStack(spacing: 0) {
            TeamInstructionSectionView()
                .padding(.top, 45)

            TeamRankingListView(
                teamRankings: teamRankings,
                userTeamName: userTeamName
            )
            .padding(.top, 36)

            Spacer()
        }
        .onAppear {
            fetchTeamRanking()
            fetchMyRanking()
        }
        .padding(.horizontal, 20)
    }
}
